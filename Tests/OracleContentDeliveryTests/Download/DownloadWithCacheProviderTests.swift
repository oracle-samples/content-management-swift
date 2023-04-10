// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest

@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal enum DeliveryDownloadTestingError: Error {
    case headersShouldNotBeEmtpyWhenStoringInCacheProvider
    case headersShouldNotBeEmtpyWhenStoringInImageProvider
}

class DownloadWithCacheProviderTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
        
        try? FileManager.default.clearDownloadDirectory()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
        
        try? FileManager.default.clearDownloadDirectory()
    }
}

extension DownloadWithCacheProviderTests {
    
    private class MyCacheProvider: CacheProvider {
        
        var cachePolicy: CachePolicy
        var itemSuccessfullyStored = false
        
        private var findURL: URL?
        private var cachedItemFilename: String?
        
        private var cachedItemError: Error?
        private var storeItemError: Error?
        
        private var headerValues: [String: String]
        
        init(cachePolicy: CachePolicy,
             findURL: URL? = nil,
             cachedItemError: Error? = nil,
             cachedItemFilename: String? = nil,
             storeItemError: Error? = nil,
             headerValues: [String: String] = [:]) {
            
            self.cachePolicy = cachePolicy
            
            self.findURL = findURL
            self.cachedItemFilename = cachedItemFilename
            
            self.cachedItemError = cachedItemError
            self.storeItemError = storeItemError
            
            self.headerValues = headerValues
            
        }
        
        func find(key: String) -> URL? {
            return self.findURL
        }
        
        func cachedItem(key: String) throws -> URL {
            
            let folderURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            if let cachedItemError = cachedItemError {
                throw cachedItemError
            }
            
            if let cachedItemFilename = cachedItemFilename {
                return folderURL.appendingPathComponent(cachedItemFilename)
            } else {
                throw OracleContentError.cacheProviderErrorNoURLAvailable
            }
        }
        
        func store(objectAt file: URL, key: String, headers: [AnyHashable: Any]) throws -> URL {
            if let storeItemError = storeItemError {
                throw storeItemError
            }
            
            itemSuccessfullyStored = true
            
            if headers.isEmpty {
                throw DeliveryDownloadTestingError.headersShouldNotBeEmtpyWhenStoringInCacheProvider
            }
            
            let filename = file.lastPathComponent
            return URL(string: "/new/file/location/\(filename)")!
        }
        
        func headerValues(for cacheKey: String) -> [String: String] {
            return self.headerValues
        }
    }
    
    func testRequest_WithCacheProvider() throws {
        let provider = MyCacheProvider(cachePolicy: .alwaysFetchWithCustomHeader, headerValues: ["If-None-Match": "abc123",
                                                                                                 "DummyKey": "dummyValue"])
        
        let sut = DeliveryAPI.downloadNative(identifier: "123", cacheProvider: provider, cacheKey: "abc")
        
        guard let request = sut.request else {
            throw OracleContentError.invalidRequest
        }
        
        let headers = request.allHTTPHeaderFields
        let etag = try XCTUnwrap(headers?["If-None-Match"])
        XCTAssertEqual(etag, "abc123")
        
        let dummy = try XCTUnwrap(headers?["DummyKey"])
        XCTAssertEqual(dummy, "dummyValue")
       
    }
    
    func testCacheProvider_BypassServerCallOnFoundItem_ItemExists() throws {
        // Turn off URL override because no server call should occur
        URLProtocolMock.stopURLOverride()
        
        let provider = MyCacheProvider(cachePolicy: .bypassServerCallOnFoundItem, findURL: URL(fileURLWithPath: "/temp/foo.png"))
        let sut = DeliveryAPI.downloadNative(identifier: "123", cacheProvider: provider, cacheKey: "abc")
        
        let returnValue = try sut.download(progress: nil).waitForFirstOutput()
        XCTAssertEqual(returnValue.result.path, "/temp/foo.png")
        XCTAssertTrue(returnValue.headers.isEmpty)
    }
    
    func testCacheProvider_BypassServerCallOnFoundItem_NoItemExists() throws {
        
        let provider = MyCacheProvider(cachePolicy: .bypassServerCallOnFoundItem)
        
        try  URLProtocolMock.enqueueDownload(
            key: .downloadNative,
            fileName: "action.png",
            bundle: DeliveryBundleHelper.bundle(for: type(of: self)),
            headers: ["Etag": "12345", "Content-Disposition": "filename=action.png"]
        )
        
        var returnValue: DownloadResult<URL>?
        let sut = DeliveryAPI.downloadNative(identifier: "123", cacheProvider: provider, cacheKey: "abc")
        returnValue = try sut.download(progress: nil).waitForFirstOutput()
        
        XCTAssertNotNil(returnValue)
        XCTAssertTrue(provider.itemSuccessfullyStored)
        
    }
    
    func testCacheProvider_BypassServerCallOnFoundItem_304Response_Success() throws {
        let provider = MyCacheProvider(cachePolicy: .bypassServerCallOnFoundItem, cachedItemFilename: "foo.png")
        
        try URLProtocolMock.enqueueCustomStringResponse(key: .downloadNative,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)
        
        var returnValue: DownloadResult<URL>?
        let sut = DeliveryAPI.downloadNative(identifier: "123", cacheProvider: provider, cacheKey: "abc")
        returnValue = try sut.download(progress: nil).waitForFirstOutput()
        
        let foundValue = try XCTUnwrap(returnValue)
        XCTAssertEqual(foundValue.result.lastPathComponent, "foo.png")
        XCTAssertFalse(provider.itemSuccessfullyStored)
    }
    
    func testCacheProvider_BypassServerCallOnFoundItem_304Response_CachedItemNotFoundInCache() throws {
        let provider = MyCacheProvider(cachePolicy: .bypassServerCallOnFoundItem)
        
        try URLProtocolMock.enqueueCustomStringResponse(key: .downloadNative,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)
        
        var returnValue: Error?
        let sut = DeliveryAPI.downloadNative(identifier: "123", cacheProvider: provider, cacheKey: "abc")
        returnValue = try sut.download(progress: nil).waitForError()
        
        let foundError = try XCTUnwrap(returnValue as? OracleContentError)
        XCTAssertEqual(foundError, OracleContentError.cacheProviderErrorNoURLAvailable)
        
    }
    
    func testCacheProvider_AlwaysFetch_Success() throws {
        let provider = MyCacheProvider(cachePolicy: .alwaysFetchWithCustomHeader, findURL: URL(fileURLWithPath: "/temp/foo.png"))
        
        try  URLProtocolMock.enqueueDownload(
            key: .downloadNative,
            fileName: "action.png",
            bundle: DeliveryBundleHelper.bundle(for: type(of: self)),
            headers: ["Etag": "12345"]
        )
        
        let sut = DeliveryAPI.downloadNative(identifier: "123", cacheProvider: provider, cacheKey: "abc")
        
        let returnValue = try sut.download(progress: nil).waitForFirstOutput()
        XCTAssertFalse(returnValue.headers.isEmpty)
        XCTAssertTrue(provider.itemSuccessfullyStored)
        
        // validate the location to which the cache provider has persisted the file
        XCTAssertEqual(returnValue.result.path, "/new/file/location/action.png")
    }
    
}
