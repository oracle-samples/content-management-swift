// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

class DeliveryDownloadThumbnailRequestTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
}

extension DeliveryDownloadThumbnailRequestTests {
    func testBaseURL() {
        
        let sut = DeliveryAPI.downloadThumbnail(identifier: "123", fileGroup: "abc").channelToken("456").version(.v1_1)
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/assets/123/thumbnail")
        XCTAssertEqual(components?.query, "type=uithumbnail&channelToken=456")
    }
    
    func testBaseURLWithOverrides() throws {
        
        URLProtocolMock.stopURLOverride()
        
        let sut = DeliveryAPI.downloadThumbnail(identifier: "123", fileGroup: "abc")
            .channelToken("456")
            .overrideURL(URL(staticString: "http://www.foo.com:2112"), headers: { ["If-None-Match": "abc123"] })
        
        let request = try XCTUnwrap(sut.request)
        let components = request.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.scheme, "http")
        XCTAssertEqual(components?.host, "www.foo.com")
        XCTAssertEqual(components?.port, 2112)
        
        let url = try XCTUnwrap(request.url)
        try XCTAssertURLContainsQueryKeyAndValue(url, "type", "uithumbnail")
        try XCTAssertURLContainsQueryKeyAndValue(url, "channelToken", "456")
        
        let headerValue = try XCTUnwrap(request.allHTTPHeaderFields?["If-None-Match"])
        XCTAssertEqual(headerValue, "abc123")
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/assets/123/thumbnail")
    }
    
}
