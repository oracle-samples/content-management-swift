// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentTest
@testable import OracleContentCore

internal class URLProtocolMockTests: XCTestCase {

    var request: URLRequest!
    
    override func setUpWithError() throws {
        
        /// Create the URLRequest
        var components = URLComponents()
        components.scheme = "http"
        components.host = "http://localhost:2112"
        components.port = 8080
        components.path = "/myDecodableObject"
        components.query = "doRetrieveMetadata=1"
        if let url = components.url {
            self.request = URLRequest(url: url)
            request.addValue("Basic blahblahblahblah==", forHTTPHeaderField: "Authorization")
        } else {
            XCTFail("Unable to create request")
        }
        
    }

    override func tearDownWithError() throws {
        Onboarding.reset()
    }

    /// Validate that a static response can be intercepted, parsed and returned
    func testProtocolMock_Success() throws {
        /****************************
         Arrange
         ****************************/
        
        struct DecodableObject: Codable {
            var name: String = ""
        }
        
        /****************************
         Arrange
         ****************************/
        var object: DecodableObject?
        let expectation = XCTestExpectation(description: "Calling web service")
        
        // enqueue the expected static response
        URLProtocolMock.enqueueDataResponse(key: .unknown, object: DecodableObject(name: "Testing123"))
        
        // set the session override so that URLs may be intercepted
        let session = URLProtocolMock.overrideSession(1.0)
        
        /****************************
         Act
         ****************************/
        // fetch the data as you normally would
        session.dataTask(with: request) { data, _, error in
            if error != nil {
                XCTFail("Error occurred while executing data task: \(error!)")
                return
            }
            
            guard let data = data else {
                XCTFail("Unable to retrieve data from the web service response")
                return
            }
            
            do {
                // deserialize the response data
                let decoder = LibraryJSONDecoder()
                object = try decoder.decode(DecodableObject.self, from: data)
                
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error while decoding the response: \(error)")
            }
        }
        .resume()
        
        self.wait(for: [expectation], timeout: 15.0)
        
        /****************************
         Assert
         ****************************/
        XCTAssertNotNil(object)
    
    }
    
    func testOverrideAndReset() {
        let testClosure = { return URL(string: "http://localhost:1234") }
        let resetClosure = Onboarding.urlProvider?.url
        
        Onboarding.baseURL = testClosure
        
        URLProtocolMock.overrideBaseURL(url: URL(string: "https://securelocalhost:443"))
        if let newURL = Onboarding.urlProvider?.url() {
            let components = URLComponents(url: newURL, resolvingAgainstBaseURL: false)
            XCTAssertEqual(components?.scheme, "https")
            XCTAssertEqual(components?.host, "securelocalhost")
            XCTAssertEqual(components?.port, 443)
        }
        
        URLProtocolMock.reset()
        if let newURL = Onboarding.urlProvider?.url() {
            let components = URLComponents(url: newURL, resolvingAgainstBaseURL: false)
            XCTAssertEqual(components?.scheme, "http")
            XCTAssertEqual(components?.host, "localhost")
            XCTAssertEqual(components?.port, 2112)
        }
        
        if resetClosure != nil {
            Onboarding.urlProvider?.url = resetClosure!
        }
        
    }
    
    func testEnqueueStringResponse() throws {
        
        let expectedURL = URL(string: "https://www.abc.com:2112")!
        let expectedValue = "Bad data"
        
        try URLProtocolMock.enqueueCustomStringResponse(
            key: .item,
            statusCode: 405,
            value: expectedValue,
            url: expectedURL,
            httpVersion: "123",
            headerFields: ["foo": "bar"]
        )
        
        guard let result = URLProtocolMock.httpURLResponse(key: SupportedURLOverrides.item.rawValue) else {
            XCTFail("Could not dequeue response")
            return
        }
        
        guard let foundData = result.0 else {
            XCTFail("No data returned")
            return
        }
        XCTAssertNotNil(result.0)
        let foundValue = String(data: foundData, encoding: .utf8)
        XCTAssertEqual(expectedValue, foundValue)
        XCTAssertEqual(result.1.statusCode, 405)
        XCTAssertEqual(result.1.allHeaderFields.count, 1)
        let fooValue = result.1.allHeaderFields["foo"] as? String
        XCTAssertEqual(fooValue, "bar")
        XCTAssertEqual(result.1.url, expectedURL)
    }
    
    func testEnqueueEmptyStringResponse() throws {

        let expectedValue = ""
        
        try URLProtocolMock.enqueueCustomStringResponse(
            key: .item,
            statusCode: 405,
            value: expectedValue
        )
        
        guard let result = URLProtocolMock.httpURLResponse(key: SupportedURLOverrides.item.rawValue) else {
            XCTFail("Could not dequeue response")
            return
        }
        
        guard let foundData = result.0 else {
            XCTFail("No data returned")
            return
        }
        XCTAssertNotNil(result.0)
        let foundValue = String(data: foundData, encoding: .utf8)
        XCTAssertEqual(expectedValue, foundValue)
       
    }
    
    func testEnqueueDictionaryResponse() throws {
     
        let expectedValue = [
            "key1": "val1",
            "key2": "val2"
        ]
        
        try URLProtocolMock.enqueueCustomDictionaryResponse(
            key: .item,
            statusCode: 405,
            value: expectedValue
        )
        
        guard let result = URLProtocolMock.httpURLResponse(key: SupportedURLOverrides.item.rawValue) else {
            XCTFail("Could not dequeue response")
            return
        }
        
        guard let foundData = result.0 else {
            XCTFail("No data returned")
            return
        }
        XCTAssertNotNil(result.0)
        let foundValue = try LibraryJSONDecoder().decode([String: String].self, from: foundData)
        XCTAssertEqual(foundValue.keys.count, 2)
        XCTAssertEqual(foundValue["key1"], "val1")
        XCTAssertEqual(foundValue["key2"], "val2")
       
        XCTAssertEqual(result.1.statusCode, 405)
    }
    
    func testEnqueueEmptyDictionaryResponse() throws {
        let expectedValue: [String: String] = [:]
         
         try URLProtocolMock.enqueueCustomDictionaryResponse(
             key: .item,
             statusCode: 405,
             value: expectedValue
         )
         
        guard let result = URLProtocolMock.httpURLResponse(key: SupportedURLOverrides.item.rawValue) else {
             XCTFail("Could not dequeue response")
             return
         }
         
         guard let foundData = result.0 else {
             XCTFail("No data returned")
             return
         }
         XCTAssertNotNil(result.0)
         let foundValue = try LibraryJSONDecoder().decode([String: String].self, from: foundData)
         XCTAssertEqual(foundValue.keys.count, 0)
        
         XCTAssertEqual(result.1.statusCode, 405)
    }
    
    func testEnqueueDownloadResponse() throws {
        try URLProtocolMock.enqueueDownload(
            key: .downloadNative,
            fileName: "action.png",
            bundle: TestBundleHelper.bundle(for: type(of: self))
        )
        
        let result = URLProtocolMock.dataResponse(key: SupportedURLOverrides.downloadNative.rawValue)
        XCTAssertNotNil(result)
    }

}

extension URLProtocolMockTests {
    /// Validate that a response with a fullfillment type of never will eventually cause a timeout 
    func testDelayedExecutionNeverCompletes() throws {
        /****************************
         Arrange
         ****************************/
        
        struct DecodableObject: Codable {
            var name: String = ""
        }
        
        /****************************
         Arrange
         ****************************/
        // enqueue the expected static response with a fulfillment type of never
        URLProtocolMock.enqueueDataResponse(key: .unknown,
                                            object: DecodableObject(name: "Testing123"),
                                            fulfillment: .never)
        
        // set the session override so that URLs may be intercepted
        let session = URLProtocolMock.overrideSession(0.5)
        
        /****************************
         Act
         ****************************/
        
        let error = try session.dataTaskPublisher(for: request).waitForError()
        
        /****************************
         Assert
         ****************************/
        XCTAssertTrue((error as NSError).code == URLError.timedOut.rawValue)
    }
    
    /// Validate that fulfillment delay greater than session timeout value will result in a timeout error
    func testDelayedExecutionWithTrueTimeout() throws {
        /****************************
         Arrange
         ****************************/
        
        struct DecodableObject: Codable {
            var name: String = ""
        }
        
        /****************************
         Arrange
         ****************************/
        // enqueue the expected static response with a delay of 2 seconds
        URLProtocolMock.enqueueDataResponse(key: .unknown,
                                            object: DecodableObject(name: "Testing123"),
                                            fulfillment: .delay(2))
        
        // set the session override so that URLs may be intercepted
        let session = URLProtocolMock.overrideSession(0.5)
        
        /****************************
         Act
         ****************************/
        
        let error = try session.dataTaskPublisher(for: request).waitForError()
        
        /****************************
         Assert
         ****************************/
        XCTAssertTrue((error as NSError).code == URLError.timedOut.rawValue)
    }

}
