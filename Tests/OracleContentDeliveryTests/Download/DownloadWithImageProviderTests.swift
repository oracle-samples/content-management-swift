// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest

@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

class DownloadWithImageProviderTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride(timeout: 100)
        
        try? FileManager.default.clearDownloadDirectory()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
        
        try? FileManager.default.clearDownloadDirectory()
    }
}

extension DownloadWithImageProviderTests {
    private class MyImageProvider: ImageProvider {
        
        var cachePolicy: CachePolicy
        var itemSuccessfullyStored = false
        
        private var findImage: OracleContentCoreImage?
        private var cachedImage: OracleContentCoreImage?
        
        private var cachedItemError: Error?
        private var storeItemError: Error?
        
        private var headerValues: [String: String]
        
        init(cachePolicy: CachePolicy,
             findImage: OracleContentCoreImage? = nil,
             cachedItemError: Error? = nil,
             cachedImage: OracleContentCoreImage? = nil,
             storeItemError: Error? = nil,
             headerValues: [String: String] = [:]) {
            
            self.cachePolicy = cachePolicy
            
            self.findImage = findImage
            self.cachedImage = cachedImage
            
            self.cachedItemError = cachedItemError
            self.storeItemError = storeItemError
            
            self.headerValues = headerValues
            
        }
        
        func find(key: String) -> OracleContentCoreImage? {
            return self.findImage
        }

        func cachedItem(key: String) throws -> OracleContentCoreImage {

            if let cachedImage = cachedImage {
                return cachedImage
            } else {
                throw OracleContentError.imageProviderErrorNoImageAvailable
            }
        }

        func store(image: OracleContentCoreImage, key: String, headers: [AnyHashable: Any]) throws {
            if let storeItemError = storeItemError {
                throw storeItemError
            }
            
            itemSuccessfullyStored = true
            
            if headers.isEmpty {
                throw DeliveryDownloadTestingError.headersShouldNotBeEmtpyWhenStoringInImageProvider
            }
        }
       
        func headerValues(for cacheKey: String) -> [String: String] {
            return self.headerValues
        }
    }
    
    func testRequest_WithImageProvider() throws {
        let provider = MyImageProvider(cachePolicy: .alwaysFetchWithCustomHeader, headerValues: ["If-None-Match": "abc123",
                                                                                                 "DummyKey": "dummyValue"])
        
        let sut = DeliveryAPI.downloadNative(identifier: "123", imageProvider: provider, cacheKey: "abc")
        
        guard let request = sut.request else {
            throw OracleContentError.invalidRequest
        }
        
        let headers = request.allHTTPHeaderFields
        let etag = try XCTUnwrap(headers?["If-None-Match"])
        XCTAssertEqual(etag, "abc123")
        
        let dummy = try XCTUnwrap(headers?["DummyKey"])
        XCTAssertEqual(dummy, "dummyValue")
       
    }
    
    func testImageProvider_BypassServerCallOnFoundItem_ItemExists() throws {
        // Turn off URL override because no server call should occur
        URLProtocolMock.stopURLOverride()
        
        let data = try XCTUnwrap(URLProtocolMock.dataFromFile("action.png", in: DeliveryBundleHelper.bundle(for: type(of: self))))
        let image = UIImage(data: data)
        
        let provider = MyImageProvider(cachePolicy: .bypassServerCallOnFoundItem, findImage: image)
        let sut = DeliveryAPI.downloadNative(identifier: "123", imageProvider: provider, cacheKey: "abc")
        
        let returnValue = try sut.downloadImage(progress: nil).waitForFirstOutput()
       
        XCTAssertTrue(returnValue.headers.isEmpty)
    }
    
    func testImageProvider_BypassServerCallOnFoundItem_NoItemExists() throws {
        
        let provider = MyImageProvider(cachePolicy: .bypassServerCallOnFoundItem)
        
        try  URLProtocolMock.enqueueDownload(
            key: .downloadNative,
            fileName: "action.png",
            bundle: DeliveryBundleHelper.bundle(for: type(of: self)),
            headers: ["Etag": "12345", "Content-Disposition": "filename=action.png"]
        )

        var returnValue: DownloadResult<OracleContentCoreImage>?
        let sut = DeliveryAPI.downloadNative(identifier: "123", imageProvider: provider, cacheKey: "abc")
        returnValue = try sut.downloadImage(progress: nil).waitForFirstOutput(timeout: 100)
        
        XCTAssertNotNil(returnValue)
        XCTAssertTrue(provider.itemSuccessfullyStored)

    }
    
    func testImageProvider_BypassServerCallOnFoundItem_304Response_Success() throws {
        
        let data = try XCTUnwrap(URLProtocolMock.dataFromFile("action.png", in: DeliveryBundleHelper.bundle(for: type(of: self))))
        let image = UIImage(data: data)
        
        let provider = MyImageProvider(cachePolicy: .bypassServerCallOnFoundItem, cachedImage: image)
        
        try URLProtocolMock.enqueueCustomStringResponse(key: .downloadNative,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)

        var returnValue: DownloadResult<OracleContentCoreImage>?
        let sut = DeliveryAPI.downloadNative(identifier: "123", imageProvider: provider, cacheKey: "abc")
        returnValue = try sut.downloadImage(progress: nil).waitForFirstOutput()
        
        XCTAssertNotNil(returnValue)
        XCTAssertFalse(provider.itemSuccessfullyStored)
    }
    
    func testImageProvider_BypassServerCallOnFoundItem_304Response_CachedItemNotFoundInCache() throws {
        let provider = MyImageProvider(cachePolicy: .bypassServerCallOnFoundItem)
        
        try URLProtocolMock.enqueueCustomStringResponse(key: .downloadNative,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)

        var returnValue: Error?
        let sut = DeliveryAPI.downloadNative(identifier: "123", imageProvider: provider, cacheKey: "abc")
        returnValue = try sut.downloadImage(progress: nil).waitForError()
        
        let foundError = try XCTUnwrap(returnValue as? OracleContentError)
        XCTAssertEqual(foundError, OracleContentError.imageProviderErrorNoImageAvailable)
       
    }
    
    func testImageProvider_AlwaysFetch_Success() throws {
        
        let data = try XCTUnwrap(URLProtocolMock.dataFromFile("action.png", in: DeliveryBundleHelper.bundle(for: type(of: self))))
        let image = UIImage(data: data)
        
        let provider = MyImageProvider(cachePolicy: .alwaysFetchWithCustomHeader, findImage: image)
        
        try  URLProtocolMock.enqueueDownload(
            key: .downloadNative,
            fileName: "action.png",
            bundle: DeliveryBundleHelper.bundle(for: type(of: self)),
            headers: ["Etag": "12345", "Content-Disposition": "filename=action.png"]
        )
        
        let sut = DeliveryAPI.downloadNative(identifier: "123", imageProvider: provider, cacheKey: "abc")
        
        _ = try sut.downloadImage(progress: nil).waitForFirstOutput()
     
        XCTAssertTrue(provider.itemSuccessfullyStored)
    }
}
