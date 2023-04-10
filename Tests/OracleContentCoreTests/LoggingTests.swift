// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore
@testable import OracleContentTest

// swiftlint:disable force_unwrapping

internal class LoggingTests: XCTestCase {

    var myLogger: TestingLoggingProvider?

    override func setUpWithError() throws {
        myLogger = TestingLoggingProvider()
        Onboarding.logger = myLogger
    }

    override func tearDownWithError() throws {
        myLogger = nil
        Onboarding.logger = nil
    }

    /// Ensure that user-provided debug logging function can be executed
    func testLogDebug() {
        Onboarding.logDebug("debugMessage")
        XCTAssertEqual(myLogger?.debugString.count, 1)
        XCTAssertEqual(myLogger?.debugString.first?.message, "debugMessage")
    }
    
    /// Ensure that user-provided error logging function can be executed
    func testLogError() {
        Onboarding.logError("errorMessage")
        XCTAssertEqual(myLogger?.errorString.count, 1)
        XCTAssertEqual(myLogger?.errorString.first?.message, "errorMessage")
    }
    
    /// Ensure that user-provided network request logging function can be executed
    func testLogNetworkRequest() {
        let session = URLSession.shared
        let request = URLRequest(url: URL(string: "http://www.somewhere.com")!)
        
        Onboarding.logNetworkRequest(request, session: session)
        XCTAssertEqual(myLogger?.networkRequestString.count, 1)
    }
    
    /// Ensure that user-provided network response logging function can be executed
    func testLogNetworkResponse() {
        let response = HTTPURLResponse()
        let data = Data()
        Onboarding.logNetworkResponseWithData(response, data: data)
        XCTAssertEqual(myLogger?.networkResponseString.count, 1)
    }

}
