// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore
@testable import OracleContentTest
import Combine

// swiftlint:disable multiline_arguments

internal class DownloadTransportTests: XCTestCase {

    var testURL: URL!
    
    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
        
        try? FileManager.default.clearDownloadDirectory()
        
        self.testURL = URL(string: "http://www.foo.com/assets/456/native")!
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
        
        try? FileManager.default.clearDownloadDirectory()
    }

}

extension DownloadTransportTests {
    
    /// Ensure that a mocked file can be enqueued for retrieval
    /// Ensure that progress is values are returned to the caller
    func testValidateProgress() throws {
        
        try  URLProtocolMock.enqueueDownload(
            key: .unknown,
            fileName: "action.png",
            bundle: CoreBundleHelper.bundle(for: type(of: self))
        )
        
        var progressOutput = [Double]()
        let request = URLRequest(url: self.testURL)
        let sut = BaseDownloadServiceTransport()
        let expectation = XCTestExpectation(description: "waiting for download to complete")
        
        sut.download(request: request) { value in
            progressOutput.append(value)
        } completion: { _ in
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 5.0)
        
        XCTAssertFalse(progressOutput.isEmpty)
    }
    
    func testSuccess() throws {
        try  URLProtocolMock.enqueueDownload(
            key: .unknown,
            fileName: "action.png",
            bundle: CoreBundleHelper.bundle(for: type(of: self))
        )
        
        let request = URLRequest(url: self.testURL)
        let sut = BaseDownloadServiceTransport()
        let expectation = XCTestExpectation(description: "waiting for download to complete")
        var returnValue: DownloadResult<URL>?
        
        sut.download(request: request) { completion in
            switch completion {
            case .success(let downloadResult):
                returnValue = downloadResult
                expectation.fulfill()
                
            default:
                XCTFail("Download request failed")
                return 
            }
        }
        
        self.wait(for: [expectation], timeout: 5.0)
        
        let expectedReturnValue = try XCTUnwrap(returnValue)
        XCTAssertEqual(expectedReturnValue.result.deletingPathExtension().lastPathComponent, "native")
    }
    
    func testFailure() throws {
        
        let expectedError = OracleContentError.invalidRequest
        URLProtocolMock.enqueueErrorResponse(key: .unknown, error: expectedError)
        
        let request = URLRequest(url: self.testURL)
        let sut = BaseDownloadServiceTransport()
        let expectation = XCTestExpectation(description: "Waiting for download to fail expectedly")
        var error: Error?
        
        sut.download(request: request) { completion in
            switch completion {
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
                
            default:
                XCTFail("Expected download service to fail but it unexpectedly completed successfully")
            }
        }
        
        self.wait(for: [expectation], timeout: 5.0)
        
        let unwrappedError = try XCTUnwrap(error)
        XCTAssertTrue(unwrappedError.matchesError(expectedError))
    }
    
}
