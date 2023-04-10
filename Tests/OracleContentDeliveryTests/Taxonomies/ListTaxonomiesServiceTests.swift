// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest 

internal class ListTaxonomiesServiceTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
}

// MARK: ChannelTokens
extension ListTaxonomiesServiceTests {
    func testSpecificChannelToken() throws {
        
        let sut = DeliveryAPI.listTaxonomies().version(.v1_1).channelToken("123")
        
        let request = sut.request
        let components = request?.url.flatMap(self.obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies")
        XCTAssertEqual(components?.query, "channelToken=123&limit=100&offset=0&totalResults=true")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testDefaultChannelToken() throws {
        Onboarding.urlProvider?.deliveryChannelToken = { return "456" }
        let sut = DeliveryAPI.listTaxonomies().version(.v1_1)
        
        let request = sut.request
        let components = request?.url.flatMap(self.obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies")
        XCTAssertEqual(components?.query, "channelToken=456&limit=100&offset=0&totalResults=true")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
}

// MARK: Limit and Offset
extension ListTaxonomiesServiceTests {
    
    func testValidateLimit() {
        let sut = DeliveryAPI.listTaxonomies().limit(99).channelToken("123")
        let components = sut.url.flatMap(obtainComponents)
        
        let foundValue = components?.queryItems?.first { $0.name == "limit" }?.value
        XCTAssertEqual(foundValue, "99")
    }
    
    func testValidateOffset() {
        let sut = DeliveryAPI.listTaxonomies().starting(at: 4).channelToken("123")
         let components = sut.url.flatMap(obtainComponents)
         
         let foundValue = components?.queryItems?.first { $0.name == "offset" }?.value
         XCTAssertEqual(foundValue, "4")
     }
}

// MARK: OrderBy
extension ListTaxonomiesServiceTests {
    
    func testOrderBy() {
        let sut = DeliveryAPI.listTaxonomies()
            .channelToken("123")
            .order(
                .name(.asc),
                .createdDate(.desc),
                .updatedDate(.asc)
            )
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
        XCTAssertEqual(foundValue, "name:asc;createdDate:desc;updatedDate:asc")
    }
}

// MARK: FetchNext
extension ListTaxonomiesServiceTests {
    
    /// Validate that the .noMoreData error is returned when when attempting a fetch
    /// that has been marked to not expect any further data to exist
    func testFetchNext_NoMoreData() {
        
        let sut = DeliveryAPI.listTaxonomies().channelToken("123")
        sut.hasMore = false
        
        XCTAssertThrowsError(try sut.fetchNext().waitForCompletion()) { error in
            XCTAssertTrue(error.matchesError(OracleContentError.noMoreData))
        }
    }
    
}

// MARK: Responses
extension ListTaxonomiesServiceTests {
    
    /// Validate that the service is able to parse values and return Repositories item
    func testStaticResponse() throws {
        
        let bundle = DeliveryBundleHelper.bundle(for: type(of: self))
        URLProtocolMock.enqueueStaticResponse(key: .taxonomies,
                                              filename: "DeliveryTaxonomies_allFields.json",
                                              bundle: bundle)
        
        let sut = DeliveryAPI.listTaxonomies().channelToken("123")
        let result = try sut.fetchNext().waitForFirstOutput()
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.totalResults, 2)
        XCTAssertFalse(sut.hasMore)
    }
    
    /// Force a web service to always return an error - without ever submitting the web service to a URLSession
    func testForceError() throws {
        URLProtocolMock.enqueueErrorResponse(
            key: .taxonomies,
            error: OracleContentError.invalidDataReturned
        )

        let error = try DeliveryAPI.listTaxonomies().channelToken("123")
            .fetchNext()
            .waitForError()
        
        XCTAssertTrue(error.matchesError(OracleContentError.invalidDataReturned))
    }
}
