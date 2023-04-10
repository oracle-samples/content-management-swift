// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class ReadTaxonomyServiceTests: XCTestCase {
    
    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }
    
    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
}

extension ReadTaxonomyServiceTests {
    
    func testSpecificChannelToken() {
        let sut = DeliveryAPI.readTaxonomy(taxonomyId: "123").version(.v1_1).channelToken("123")
        
        let request = sut.request
        let components = sut.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies/123")
        XCTAssertEqual(components?.query, "channelToken=123")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testDefaultChannelToken() throws {
        Onboarding.urlProvider?.deliveryChannelToken = { return "456" }
        let sut = DeliveryAPI.readTaxonomy(taxonomyId: "123").version(.v1_1)
        
        let request = sut.request
        let components = sut.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/taxonomies/123")
        XCTAssertEqual(components?.query, "channelToken=456")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testNotWellFormed() throws {
        let sut = DeliveryAPI.readTaxonomy(taxonomyId: "")
        let result = try sut.fetch().waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "Taxonomy ID cannot be empty.")
    }

}

// MARK: Additional Headers
extension ReadTaxonomyServiceTests {
    
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

