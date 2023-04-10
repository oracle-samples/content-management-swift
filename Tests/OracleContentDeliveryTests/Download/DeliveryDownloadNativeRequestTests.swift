// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class DeliveryDownloadNativeRequestTests: XCTestCase {
    
    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }
    
    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
    
}

extension DeliveryDownloadNativeRequestTests { 
    func testBaseURL() {
        
        let sut = DeliveryAPI.downloadNative(identifier: "123").channelToken("456").version(.v1_1)
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/assets/123/native")
        XCTAssertEqual(components?.query, "channelToken=456")
    }
    
    func testNotWellFormed() throws {
        let sut = DeliveryAPI.downloadNative(identifier: "")
        let result = try sut.download(progress: nil).waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "Asset identifier cannot be empty.")
    }
}
