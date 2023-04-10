// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
@testable import OracleContentCore
@testable import OracleContentDelivery
@testable import OracleContentTest

import XCTest

internal class DownloadNativeTests: XCTestCase {
    
    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
        
        try? FileManager.default.clearDownloadDirectory()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
        
        try? FileManager.default.clearDownloadDirectory()
    }

}

extension DownloadNativeTests {
    
    /// Ensure that a mocked file can be enqueued for retrieval
    /// Ensure that progress is values are returned to the caller
    func testValidateProgress() throws {
        
        try  URLProtocolMock.enqueueDownload(
            key: .downloadNative,
            fileName: "action.png",
            bundle: DeliveryBundleHelper.bundle(for: type(of: self))
        )
        
        var progressOutput = [Double]()
        let sut = DeliveryAPI.downloadNative(identifier: "123").channelToken("456")
        
        _ = try sut.download { value in
            progressOutput.append(value)
        }
        .waitForFirstOutput()
        
        XCTAssertFalse(progressOutput.isEmpty)
    }
    
    func testSuccess() throws {
        try  URLProtocolMock.enqueueDownload(
            key: .downloadNative,
            fileName: "action.png",
            bundle: DeliveryBundleHelper.bundle(for: type(of: self))
        )
        
        let sut = DeliveryAPI.downloadNative(identifier: "123").channelToken("456")
        let returnValue = try sut.download(progress: nil).waitForFirstOutput()
        
        XCTAssertEqual(returnValue.result.deletingPathExtension().lastPathComponent, "native")
    }
    
    func testFailure() throws {
        
        let expectedError = OracleContentError.invalidRequest
        URLProtocolMock.enqueueErrorResponse(key: .downloadNative, error: expectedError)
        
        let sut = DeliveryAPI.downloadNative(identifier: "123").channelToken("456")
        let error = try sut.download(progress: nil).waitForError(timeout: 5)
        XCTAssertTrue(error.matchesError(expectedError))
        
    }
    
}
