// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentTest
import OracleContentCore
import Combine

class SupportedURLOverridesTests: XCTestCase {

    var cancellables = [AnyCancellable]()
    
    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }

    func testItemPath() {
        let itemRequestPath = SupportedURLOverrides.item.itemsRequestPath()
        XCTAssertEqual(itemRequestPath.path, "items/{id}")
        XCTAssertEqual(itemRequestPath.requestType, .get)
    }
    
    func testValidateItemKey() {
        let url = URL(staticString: "http://www.foo.com:2112/content/management/api/v1.1/items/12345")
        let request = URLRequest(url: url)
        let key = SupportedURLOverrides.key(for: request)
        XCTAssertEqual(key, SupportedURLOverrides.item.rawValue)
    }
    
    func testValidateAssetBySlug() {
        let url = URL(staticString: "http://www.foo.com:2112/content/management/api/v1.1/items/.by.slug/12345")
        let request = URLRequest(url: url)
        let key = SupportedURLOverrides.key(for: request)
        XCTAssertEqual(key, SupportedURLOverrides.assetBySlug.rawValue)
    }
}
