// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import Combine
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

internal class DeliveryDownloadRenditionRequestTests: XCTestCase {
    
    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }
    
    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
    
}

extension DeliveryDownloadRenditionRequestTests { 
    func testBaseURL() {
        
        let sut = DeliveryAPI.downloadRendition(identifier: "123", renditionName: "foo")
            .channelToken("456")
            .version(.v1_1)
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/assets/123/foo")
        XCTAssertEqual(components?.query, "channelToken=456")
    }
    
    func testFormat() {
        let sut = DeliveryAPI.downloadRendition(identifier: "123", renditionName: "foo", format: "bar")
            .channelToken("456")
            .version(.v1_1)
        
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/assets/123/foo")
        XCTAssertEqual(components?.query, "channelToken=456&format=bar")
    }
    
    func testRenditionType() {
        let sut = DeliveryAPI.downloadRendition(identifier: "123", renditionName: "foo", type: "bar")
            .channelToken("456")
            .version(.v1_1)
        
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/assets/123/foo")
        XCTAssertEqual(components?.query, "channelToken=456&type=bar")
    }
    
    func testFormat_Both() {
        let sut = DeliveryAPI.downloadRendition(identifier: "123", renditionName: "foo", format: "  foo  ", type: "  bar  ")
            .channelToken("456")
            .version(.v1_1)
        
        let request = sut.request
        let components = request?.url.flatMap(obtainComponents)
        
        XCTAssertEqual(components?.path, "/content/published/api/v1.1/assets/123/foo")
        XCTAssertEqual(components?.query, "channelToken=456&format=foo&type=bar")
    }
    
    func testNotWellFormed() throws {
        let sut = DeliveryAPI.downloadRendition(identifier: "", renditionName: "foo")
        let result = try sut.download(progress: nil).waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "Asset identifier cannot be empty.")
    }
    
    func testNotWellFormed_RenditionName() throws {
        let sut = DeliveryAPI.downloadRendition(identifier: "123", renditionName: "")
        let result = try sut.download(progress: nil).waitForError()
        try XCTAssertErrorTypeMatchesInvalidURL(result, "Rendition name cannot be empty.")
    }
    
    func testNotWellFormed_EmptyAssetId() throws {
        let sut = DeliveryAPI.readAsset(assetId: "")
        let isWellFormed = sut.serviceParameters.isWellFormed()
        XCTAssertFalse(isWellFormed)
        
        guard let foundError = sut.serviceParameters.invalidURLError,
              case OracleContentError.invalidURL(let text) = foundError else {
                  XCTFail("Invalid error type returned")
                  return
              }
        
        XCTAssertEqual(text, "Asset ID cannot be empty.")
    }
}
