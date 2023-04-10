// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import OracleContentTest
import OracleContentCore
import OracleContentDelivery
import Combine

final class ListTaxonomyCategoriesTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
}

extension ListTaxonomyCategoriesTests {
    
//    func testParseResponse() throws {
//        let data = ListTaxonomyCategoriesTests.jsonString.data(using: .utf8)!
//        let taxonomyCategories = try LibraryJSONDecoder().decode(TaxonomyCategories.self, from: data)
//
//        XCTAssertEqual(taxonomyCategories.items.count, 1)
//        XCT(taxonomyCategories.)
//    }
    
    func testSpecificChannelToken() throws {
        
        let sut = DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").version(.v1_1).channelToken("123")
        
        let request = sut.request
        let components = request?.url.flatMap(self.obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies/4567/categories")
        XCTAssertEqual(components?.query, "channelToken=123&limit=100&offset=0&totalResults=true")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testDefaultChannelToken() throws {
        Onboarding.urlProvider?.deliveryChannelToken = { return "456" }
        let sut = DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").version(.v1_1)
        
        let request = sut.request
        let components = request?.url.flatMap(self.obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies/4567/categories")
        XCTAssertEqual(components?.query, "channelToken=456&limit=100&offset=0&totalResults=true")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
}

// MARK: Limit and Offset
extension ListTaxonomyCategoriesTests {
    
    func testValidateLimit() {
        let sut = DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").limit(99).channelToken("123")
        let components = sut.url.flatMap(obtainComponents)
        
        let foundValue = components?.queryItems?.first { $0.name == "limit" }?.value
        XCTAssertEqual(foundValue, "99")
    }
    
    func testValidateOffset() {
        let sut = DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").starting(at: 4).channelToken("123")
         let components = sut.url.flatMap(obtainComponents)
         
         let foundValue = components?.queryItems?.first { $0.name == "offset" }?.value
         XCTAssertEqual(foundValue, "4")
     }
}

// MARK: OrderBy
extension ListTaxonomyCategoriesTests {
    
    func testOrderBy() {
        let sut = DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").channelToken("123").order(.name(.asc), .position(.desc))
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
        XCTAssertEqual(foundValue, "name:asc;position:desc")
    }
}

// MARK: FetchNext
extension ListTaxonomyCategoriesTests {
    
    /// Validate that the .noMoreData error is returned when when attempting a fetch
    /// that has been marked to not expect any further data to exist
    func testFetchNext_NoMoreData() {
        
        let sut = DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").channelToken("123")
        sut.hasMore = false
        
        XCTAssertThrowsError(try sut.fetchNext().waitForCompletion()) { error in
            XCTAssertTrue(error.matchesError(OracleContentError.noMoreData))
        }
    }
    
}

// MARK: Responses
extension ListTaxonomyCategoriesTests {
    
    /// Validate that the service is able to parse values and return Repositories item
    func testStaticResponse() throws {
        
        let bundle = DeliveryBundleHelper.bundle(for: type(of: self))
        URLProtocolMock.enqueueStaticResponse(key: .taxonomyCategories,
                                              filename: "DeliveryTaxonomyCategories_allFields.json",
                                              bundle: bundle)
        
        let sut = DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").channelToken("123")
        let result = try sut.fetchNext().waitForFirstOutput()
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.totalResults, 1)
        XCTAssertFalse(sut.hasMore)
    }
    
    /// Force a web service to always return an error - without ever submitting the web service to a URLSession
    func testForceError() throws {
        URLProtocolMock.enqueueErrorResponse(
            key: .taxonomyCategories,
            error: OracleContentError.invalidDataReturned
        )

        let error = try DeliveryAPI.listTaxonomyCategories(taxonomyId: "4567").channelToken("123")
            .fetchNext()
            .waitForError()
        
        XCTAssertTrue(error.matchesError(OracleContentError.invalidDataReturned))
    }
}
