// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class ReadAssetServiceTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
    
}

// MARK: URL Tests
extension ReadAssetServiceTests {
    
    func testURLPrefix() {
        let sut = DeliveryAPI.readAsset(assetId: "123")
                             .version(.v1_1)
                             .channelToken("123")
        
        let components = sut.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.scheme, "http")
        XCTAssertEqual(components?.host, "localhost")
        XCTAssertEqual(components?.port, 2112)
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/items/123")
        XCTAssertEqual(components?.query, "channelToken=123&expand=all")
        XCTAssertEqual(sut.request?.httpMethod, "GET")
    }
    
    func testOverrideURLPrefix() {
        let overrideURL = URL(string: "https://www.foo.com:1234")!
        
        let sut = DeliveryAPI.readAsset(assetId: "123")
                             .channelToken("123")
                             .overrideURL(overrideURL)
                             .version(.v1_1)
        
        let components = sut.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, "www.foo.com")
        XCTAssertEqual(components?.port, 1234)
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/items/123")
    }
    
    func testSlug_URLPrefix() {
        let sut = DeliveryAPI.readAsset(slug: "123")
                             .channelToken("123")
                             .version(.v1_1)
        
        let components = sut.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.scheme, "http")
        XCTAssertEqual(components?.host, "localhost")
        XCTAssertEqual(components?.port, 2112)
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/items/.by.slug/123")
        XCTAssertEqual(components?.query, "channelToken=123&expand=all")
        XCTAssertEqual(sut.request?.httpMethod, "GET")
    }

}

// MARK: Responses
extension ReadAssetServiceTests {
    
    func testNotWellFormed_EmptySlug() throws {
        let sut = DeliveryAPI.readAsset(slug: "")
        let result = try sut.fetch().waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "Slug cannot be empty.")
    }
    
    func testNotWellFormed_EmptyAssetId() throws {
        let sut = DeliveryAPI.readAsset(assetId: "")
        let result = try sut.fetch().waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "Asset ID cannot be empty.")
    }
    
    func testByAssetId() throws {
        let bundle = DeliveryBundleHelper.bundle(for: type(of: self))
        
        URLProtocolMock.enqueueStaticResponse(key: .item,
                                              filename: "singleContentItem.json",
                                              bundle: bundle)
        
        let sut = DeliveryAPI.readAsset(assetId: "COREF626EC6D55534DA08D5E644ED3F81DAB").channelToken("123")
        
        let result = try sut.fetch().waitForFirstOutput()
        
        XCTAssertEqual(result.identifier, "COREF626EC6D55534DA08D5E644ED3F81DAB")
    }
    
    func testBySlug() throws {
        let bundle = DeliveryBundleHelper.bundle(for: type(of: self))
        
        URLProtocolMock.enqueueStaticResponse(key: .assetBySlug,
                                              filename: "singleContentItem.json",
                                              bundle: bundle)
        
        let sut = DeliveryAPI.readAsset(slug: "1481786051613-fabtestcontentitem").useNoCacheSession().channelToken("123")
        
        let result = try sut.fetch().waitForFirstOutput()
        
        XCTAssertEqual(result.identifier, "COREF626EC6D55534DA08D5E644ED3F81DAB")
    }

}

// MARK: Additional Headers
extension ReadAssetServiceTests {
    
    /// Validate that additional header values can be added without replacing existing authorization headers
    func testAdditionalHeaders() throws {
        let sut = DeliveryAPI.readAsset(slug: "123")
                             .channelToken("123")
                             .additionalHeaders(["foo": "bar", "Authorization": "KeithStuff"])
        
        let request = try XCTUnwrap(sut.request)
        
        // ensure that additional header value exists
        let receivedHeaderValue = try XCTUnwrap(request.value(forHTTPHeaderField: "foo"))
        XCTAssertEqual(receivedHeaderValue, "bar")
        
        // ensure that original Authorization header still exists
        // (Authorization headers, when available, are added for ReadAsset service calls so
        // that secure channels can be accessed)
        XCTAssertNotNil(request.value(forHTTPHeaderField: "Authorization"))
    }
    
    /// Validate that additional headers can be added without replacing the override authorization headers from `ImplementsOverrides`
    func testAdditionalHeadersWithAuthorizationOverrides() throws {
        let sut = DeliveryAPI.readAsset(slug: "123")
                             .channelToken("123")
                             .additionalHeaders(["foo": "bar"])
                             .overrideURL(URL(staticString: "http://foo.com")) {
                                 ["newAuthHeader": "newAuthValue"]
                             }
        
        let request = try XCTUnwrap(sut.request)
        
        // ensure that additional header value exists
        let receivedHeaderValue = try XCTUnwrap(request.value(forHTTPHeaderField: "foo"))
        XCTAssertEqual(receivedHeaderValue, "bar")
        
        // ensure that original Authorization header is nil - that header is overwritten when authorization headers are provided as part of `overrideURL`
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        
        // ensure that new authorization header is present
        let newAuthHeaderValue = try XCTUnwrap(request.value(forHTTPHeaderField: "newAuthHeader"))
        XCTAssertEqual(newAuthHeaderValue, "newAuthValue")
    }
}

extension ReadAssetServiceTests {
    func testCallerInvokedService() throws {
        try URLProtocolMock.enqueueCustomStringResponse(key: .item,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)

        let service = DeliveryAPI.readAsset(assetId: "123")
        let session = Onboarding.sessions.session()
        let request = service.request!

        let result = try session.dataTaskPublisher(for: request.url!).waitForFirstOutput()
        
        let urlResponse = try XCTUnwrap(result.response as? HTTPURLResponse)
        XCTAssertEqual(urlResponse.statusCode, 304)
        
    }
    
    func testPerformDataTask() throws {

        let expectation = XCTestExpectation(description: "Waiting for service")
        
        try URLProtocolMock.enqueueCustomStringResponse(key: .item,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)
        var foundData: Data?
        var foundResponse: URLResponse?
        var foundError: Error?
        
        DeliveryAPI.readAsset(assetId: "123").channelToken("123").fetchAsDataTask { data, response, error in
            foundData = data
            foundResponse = response
            foundError = error
            
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNil(foundError)
        
        let receivedData = try XCTUnwrap(foundData)
        XCTAssertEqual(receivedData.count, 0)
        
        let urlResponse = try XCTUnwrap(foundResponse as? HTTPURLResponse)
        XCTAssertEqual(urlResponse.statusCode, 304)

    }
}
