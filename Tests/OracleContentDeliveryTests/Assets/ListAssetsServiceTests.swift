// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest

@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class ListAssetsServiceTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }

}

extension ListAssetsServiceTests {
    func testSearchItems() {
        
        let sut = DeliveryAPI.listAssets().version(.v1_1).channelToken("123")
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)

        XCTAssertEqual(components?.path, "/content/published/api/v1.1/items")
        XCTAssertEqual(components?.query, "channelToken=123&limit=100&offset=0&totalResults=true")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testSingleItem() {
        let sut = DeliveryAPI.readAsset(assetId: "123").channelToken("123")
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/items/123")
        XCTAssertEqual(components?.query, "channelToken=123&expand=all")
        XCTAssertEqual(request?.httpMethod, "GET")
    }

    func testSingleItemBySlug() {
        let sut = DeliveryAPI.readAsset(slug: "123").channelToken("123")
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/items/.by.slug/123")
        XCTAssertEqual(components?.query, "channelToken=123&expand=all")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
}

// Sort Order
extension ListAssetsServiceTests {
    
    func testSortOrder() throws {
        let sut = DeliveryAPI.listAssets().order(.field("name", .asc), .field("fields.foo", .desc))
        
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
        XCTAssertEqual(foundValue, "name:asc;fields.foo:desc")
    }
}

extension ListAssetsServiceTests {
    func testCallerInvokedService() throws {
        try URLProtocolMock.enqueueCustomStringResponse(key: .items,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)

        let service = DeliveryAPI.listAssets().channelToken("123")
        let session = Onboarding.sessions.session()
        let request = service.request!

        let result = try session.dataTaskPublisher(for: request.url!).waitForFirstOutput()
        
        let urlResponse = try XCTUnwrap(result.response as? HTTPURLResponse)
        XCTAssertEqual(urlResponse.statusCode, 304)
        
    }
    
    func testPerformDataTask() throws {

        let expectation = XCTestExpectation(description: "Waiting for service")
        
        try URLProtocolMock.enqueueCustomStringResponse(key: .items,
                                                        statusCode: 304,
                                                        value: nil,
                                                        url: nil,
                                                        httpVersion: nil,
                                                        headerFields: nil)
        var foundData: Data?
        var foundResponse: URLResponse?
        var foundError: Error?
        
        DeliveryAPI.listAssets().channelToken("123").fetchNextAsDataTask { data, response, error in
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
