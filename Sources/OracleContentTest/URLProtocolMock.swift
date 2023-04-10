// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore
import Combine

//swiftlint:disable force_unwrapping

/// The URLProtocolMock class is used to allow integration testing code to intercept web service calls and return previously enqueued responses.
///
/// Testing usage often follows patterns such as this:
/// ```swift
/// override func setUpWithError() throws {
///    URLProtocolMock.startURLOverride()
/// }
///
/// override func tearDownWithError() throws {
///    URLProtocolMock.stopURLOverride()
/// }
///
/// func testResponse() throws {
///    let mockAsset = Asset()
///    mockAsset.identifier = "2112"
///    URLProtocolMock.enqueueDataResponse(key: .item, object: mockAsset)
///
///    let sut = DeliveryAPI.readAsset(assetId: "123")
///    let result = try sut.fetch().waitForFirstOutput()
///
///    XCTAssertEqual(result.identifier, "2112"
/// }
/// ```
///
/// - important: You must call `startURLOverride()` in order to intercept web service calls. You must call `stopURLOverride()` when done.
/// - important: You must
public class URLProtocolMock: URLProtocol {
    
    /// Class function which injects a testing URLSessionConfiguration configured to intercept web service calls and fulfill them with enqueued responses.
    ///
    /// This is most-often called from within testing code as part of setup methods.
    /// ```swift
    ///override func setUpWithError() throws {
    ///   URLProtocolMock.startURLOverride()
    ///}
    ///
    ///override func tearDownWithError() throws {
    ///    URLProtocolMock.stopURLOverride()
    ///}
    /// ```
    ///
    /// - important: If you call `startURLOverride`, you must also make sure to call `stopURLOverride`
    ///
    /// - parameter URL?: The optional URL to use as the base URL in Onboarding
    /// - parameter timeout: The timeout value to use for created URLSessions. Defaults to 1 second
    /// - parameter additionalURLOverrides: An array of OverrideProtocol.Type objects. These objects provide a static function to obtain the "key" for a given URLRequest. You may choose to pass the additional override types here. You may also choose to programmatically provide an additional override value while enqueueing an expected response type.
    public class func startURLOverride(_ url: URL? = nil,
                                       timeout: Double = 1.0,
                                       additionalURLOverrides: [OverrideProtocol.Type] = []) {
        let overrideURL = url ?? URL(string: "http://localhost:2112")
        URLProtocolMock.overrideBaseURL(url: overrideURL)

        self.existingLoggingProvider = Onboarding.logger
        self.existingSessionProvider = Onboarding.sessions
        self.existingURLProvider = Onboarding.urlProvider
        
        self.additionalURLOverrides = additionalURLOverrides
        
        Onboarding.sessions = TestingSessionProvider(timeout: timeout)
        Onboarding.logger = TestingLoggingProvider()
        Onboarding.urlProvider = TestingURLProvider()
    }
    
    /// Class function which resets the URLSession functionality in `OracleContentCore.Onboarding` to its previous values
    ///
    /// This should be called in testing code, following a prior call to `startURLOverride`
    /// ```swift
    ///override func setUpWithError() throws {
    ///   URLProtocolMock.startURLOverride()
    ///}
    ///
    ///override func tearDownWithError() throws {
    ///    URLProtocolMock.stopURLOverride()
    ///}
    /// ```
    ///
    public class func stopURLOverride() {
        URLProtocolMock.reset()
    }
    
    /// Provide an overridden URLSession that uses:  an ephemeral configuration configured to intercept web service calls.
    /// - returns: (`Double`?) -> `URLSession`
    ///
    /// Returns a function that takes an optional Double value and returns a URLSession.  The Double value represents an optional timeout value
    /// for the session. If no value is supplied, the timeout defaults to 1 second
    public static var overrideSession: (Double?) -> URLSession = { timeout in
        
        let timeout = timeout ?? 1.0
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        return session
    }
    /// Other test packages conforming to OverrideProtocol should call this method to ensure that their type is added to the collection of additionalURLOverrides
    public static func addOverride(_ overrideType: OverrideProtocol.Type) {
        if !self.containsOverride(overrideType) {
            self.additionalURLOverrides.append(overrideType)
        }
    }
    
    /// PassthroughSubject of all URLRequests that are received by URLProtocolMock
    public static var outgoingURLRequests = PassthroughSubject<URLRequest, Never>()
    
    /// Map of keys to array of `ResponseType`. This is the location to which expected responses are enqueued
    internal static var staticResponses = [String: [ResponseType]]()
    
    /// Map of keys to array of `RepeatingResponse`. This is the location to which repeating responses are enqueued.
    internal static var repeatingResponses = [String: RepeatingResponse]()
    
    /// The saved off value for BaseURL. Retrieved as part of `startURLOverride` and restored as part of `stopURLOverride`
    internal static var existingBaseURL: (() -> URL?)?
    
    /// The saved off value for Logging Provider. Retrieved as part of `startURLOverride` and restored as part of `stopURLOverride`
    internal static var existingLoggingProvider: LoggingProvider?
    
    /// The saved off value for Session Provider. Retrieved as part of `startURLOverride` and restored as part of `stopURLOverride`
    internal static var existingSessionProvider: SessionProvider?
    
    /// The saved off value for URL Provider. Retrieved as part of `startURLOverride` and restored as part of `stopURLOverride`
    internal static var existingURLProvider: URLProvider?
    
    /// The collection of types conforming to `OverrideProtocol`.  This is used when determining whether we can obtain a key from a given URLRequest.
    internal static var additionalURLOverrides = [OverrideProtocol.Type]()
    
    /// Internal method which determines whether the specified overrideType already exists in the collection of additionalURLOverrides
    internal static func containsOverride(_ overrideType: OverrideProtocol.Type) -> Bool {
        return self.additionalURLOverrides.contains {
            return $0 == overrideType
        }
    }
}

// MARK: URLProtocol
extension URLProtocolMock {
    
    /// Overridden implementation to indicate that we want to handle all types of requests
    public override class func canInit(with request: URLRequest) -> Bool {
        // URLProtocolMock will intercept EVERY web service request it receives
        return true
    }
    
    /// Overridden implementation to indicate that we want to handle all types of tasks
    public override class func canInit(with task: URLSessionTask) -> Bool {
        // URLProtocolMock will intercept EVERY web service request it receives
        return true 
    }
    
    /// Overridden implementation to indicate that we are really just ignoring this method by sending back what we were given
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    /// Overridden implementation to intercept the URL and provide our own static response
    public override func startLoading() {
        URLProtocolMock.outgoingURLRequests.send(request)
        
        let key = self.key(for: request) ?? SupportedURLOverrides.unknown.rawValue
        
        if let (data, fulfillment) = URLProtocolMock.dataResponse(key: key),
           let foundData = data,
           let delay = fulfillment.delayTime() {
        
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let response = URLResponse(
                      url: self.request.url!,
                      mimeType: nil,
                      expectedContentLength: foundData.count,
                      textEncodingName: nil
                    )
                    
                     self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

                     self.client?.urlProtocol(self, didLoad: foundData)
                     self.client?.urlProtocolDidFinishLoading(self)
                }
            
        } else if let (errorResult, fulfillment) = URLProtocolMock.errorResponse(key: key),
               let foundError = errorResult,
               let delay = fulfillment.delayTime() {
            
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.client?.urlProtocol(self, didFailWithError: foundError)
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            
        } else if let (data, httpURLResponse, fulfillment) = URLProtocolMock.httpURLResponse(key: key),
                  let delay = fulfillment.delayTime() {
            
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if let foundData = data {
                        self.client?.urlProtocol(self, didLoad: foundData)
                    }
                    
                    self.client?.urlProtocol(self, didReceive: httpURLResponse, cacheStoragePolicy: .notAllowed)
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            
        } else {
            print("URLProtocolMock will not handle response for the current request.")
            print("Either the data was not properly enqueued or the fulfillment schedule was set to .never")
        }
        
    }
    
    /// Overridden implementation which is required but doesn't need to do anything
    public override func stopLoading() { }
}

extension URLProtocolMock {
    
    /// Return the key that matches a URLRequest
    ///
    /// Look through all available `OverrideProtocol` objects provided and find the first key that matches the specified request. `OverrideProtocol` provides a static method to obtain this value
    /// - parameter request: URLRequest to inspect
    /// - returns: String? The key, if found, else nil
    internal func key(for request: URLRequest) -> String? {
        
        // Look first in SupportedURLOverrides, then iterate through the collection of additionalURLOverrides
        guard let returnValue = SupportedURLOverrides.key(for: request) else {
            
            let externalOverride = URLProtocolMock
                .additionalURLOverrides
                .compactMap {
                    $0.key(for: request)
                }
                .first
            
            guard let foundExternalOverride = externalOverride else {
                return nil
            }
    
            return foundExternalOverride
            
        }
 
        return returnValue
    }
}

// MARK: Enqueuing Methods
extension URLProtocolMock {
    /// The intended user-facing method to add a response for the specified key. Testing code should call this method directly. You can add any object that conforms to Encodable
    ///
    /// This is probably the most-used enqueueing function in URLProtocolMock. The classic example, is that you have some mock object that you want returned as part a web service call.
    /// In the Delivery library, perhaps you have a mock Asset that should be returned as part of an integration test.  You could perform the following to create a mock Assert and enqueue it so that it will be returned as part of a service call to read an asset.
    ///
    /// ```swift
    ///   var mockAsset = Asset()
    ///   mockAsset.identifier = "2112"
    ///   // specify other property values
    ///
    ///   URLProtocolMock.enqueueDataResponse(key: .item, object: mockAsset)
    ///  ```
    ///
    /// - note: key and object are the only required values
    /// - note: fulfillment value of .immediate (the default value) means no delay in serving the response. A value of .delay(2) means, "introduce a 2 second delay before serving the response." A value of .never means do not ever serve the response and instead wait for the service call to timeout
    /// - parameter key: A SupportedURLOverrides value the determines the type of the web service to handle
    /// - parameter object: Generic object of type T that will be encoded as part of of enqueueing and decoded as part of dequeueing.
    /// - parameter repeating: The number of times this response should be repeatedly served for a matching service call. Defaults to `.noRepeats`
    /// - parameter fullfillment: A `FulfillmentSchedule` value allowing for the introduction of delays before serving the response. The default value is .immediate meaning no delay.
    public static func enqueueDataResponse<T: Encodable>(key: SupportedURLOverrides,
                                                         object: T,
                                                         repeating: RepeatingResponse = .noRepeats,
                                                         fulfillment: FulfillmentSchedule = .immediate) {
        genericEnqueueDataResponse(key: key.rawValue, object: object, repeating: repeating, fulfillment: fulfillment)
        
    }
    
    /// The intended user-facing method to add a static response for the specified key from the filename specified. Testing code should call this method directly
    ///
    /// This method is useful for cases where it may be too difficult to create a mock object solely in code. Instead, you can create a JSON file containing the serialized version of an object.
    ///
    /// ```swift
    /// let myJSONFile = "ListOf100Assets.json"
    /// URLProtocolMock.enqueueStaticResponse(key: items, filename: myJSONFile, bundle: Bundle(for: type(of: self)))
    /// ```
    ///
    /// - note: key, filename and bundle are the only required values.
    /// - note: fulfillment value of .immediate (the default value) means no delay in serving the response. A value of .delay(2) means, "introduce a 2 second delay before serving the response." A value of .never means do not ever serve the response and instead wait for the service call to timeout
    /// - parameter key: A SupportedURLOverrides value the determines the type of the web service to handle
    /// - parameter filename: The static file containing the JSON response that should be used. If you specify a file extension as part of the file name,
    /// it will be used.  Otherwise, ".json" will be inferred.
    /// - parameter bundle: The Bundle containing the file to load
    /// - parameter repeating: The number of times this response should be repeatedly served for a matching service call. Defaults to `.noRepeats`
    /// - parameter fullfillment: A `FulfillmentSchedule` value allowing for the introduction of delays before serving the response. The default value is .immediate meaning no delay.
    public static func enqueueStaticResponse(key: SupportedURLOverrides,
                                             filename: String,
                                             bundle: Bundle,
                                             repeating: RepeatingResponse = .noRepeats,
                                             fulfillment: FulfillmentSchedule = .immediate) {
        genericEnqueueStaticResponse(key: key.rawValue, filename: filename, bundle: bundle, repeating: repeating)
    }
    
    /// The intended user-facing method to add an Error response for the specified key. Testing code should call this method directly
    ///
    /// ```swift
    ///    URLProtocolMock.enqueueErrorResponse(key: .item, error: MyError.someTestingError)
    /// ```
    ///
    /// - note: key and error are the only required values
    /// - note: fulfillment value of .immediate (the default value) means no delay in serving the response. A value of .delay(2) means, "introduce a 2 second delay before serving the response." A value of .never means do not ever serve the response and instead wait for the service call to timeout
    /// - parameter key: A SupportedURLOverrides value the determines the type of the web service to handle
    /// - parameter error: The Error to return as part of web service fulfillment
    /// - parameter repeating: The number of times this response should be repeatedly served for a matching service call. Defaults to `.noRepeats`
    /// - parameter fullfillment: A `FulfillmentSchedule` value allowing for the introduction of delays before serving the response. The default value is .immediate meaning no delay.
    public static func enqueueErrorResponse(key: SupportedURLOverrides,
                                            error: Error,
                                            repeating: RepeatingResponse = .noRepeats,
                                            fulfillment: FulfillmentSchedule = .immediate) {
        genericEnqueueErrorResponse(key: key.rawValue, error: error, repeating: repeating)
    }
    
    /// The intended user-facing method to provide a download response for the specified key using the contents of the specified file. Testing code should call this method directly
    ///
    /// Suppose an integration test required a download service to complete. You could serve up download results based on the contents of a file by doing the following:
    ///
    /// ```swift
    ///
    /// URLProtocolMock.enqueueDownload(key: .downloadNative, filename: "sample.png", bundle: Bundle(for: type(of: self)))
    /// ```
    ///
    /// - note: key, filename and bundle are the only required values.
    /// - note: fulfillment value of .immediate (the default value) means no delay in serving the response. A value of .delay(2) means, "introduce a 2 second delay before serving the response." A value of .never means do not ever serve the response and instead wait for the service call to timeout
    /// - parameter key: A SupportedURLOverrides value the determines the type of the web service to handle
    /// - parameter filename: The name of the file whose contents will represent the download
    /// - parameter bundle: The Bundle containing the file to load
    /// - parameter repeating: The number of times this response should be repeatedly served for a matching service call. Defaults to `.noRepeats`
    /// - parameter fullfillment: A `FulfillmentSchedule` value allowing for the introduction of delays before serving the response. The default value is .immediate meaning no delay.
    /// - parameter statusCode: Used when converting a download response to  an HTTPURLResponse
    /// - parameter headers: When headers are specified, an HTPPURLResponse will be returned
    public static func enqueueDownload(key: SupportedURLOverrides,
                                       fileName: String,
                                       bundle: Bundle,
                                       repeating: RepeatingResponse = .noRepeats,
                                       fulfillment: FulfillmentSchedule = .immediate,
                                       statusCode: Int = 200,
                                       headers: [String: String] = [:]) throws {
        try genericEnqueueDownload(key: key.rawValue,
                            fileName: fileName,
                            bundle: bundle,
                            repeating: repeating,
                            fulfillment: fulfillment,
                            statusCode: statusCode,
                            headers: headers)
    }
    
    /// The intended user-facing method to provide a custom response including status code, string based values, header fields, etc.
    ///
    /// Suppose that you wanted to enqueue a response with a 405 status code and response body of "Method not allowed"
    /// ```swift
    /// try URLProtocolMock.enqueueCustomStringResponse(
    ///    key: .item,
    ///    statusCode: 406,
    ///    value: "Method not allowed"
    /// )
    /// ```
    ///
    /// Additionallly, more complex responses can be generated
    ///```swift
    /// let expectedURL = URL(string: "https://www.abc.com:2112")!
    /// let expectedValue = "Bad data"
    ///
    /// try URLProtocolMock.enqueueCustomStringResponse(
    ///     key: .item,
    ///     statusCode: 405,
    ///     value: expectedValue,
    ///     url: expectedURL,
    ///     httpVersion: "123",
    ///     headerFields: ["foo": "bar"]
    /// )
    ///```
    ///
    /// - note: key and status code are the only required values.
    /// - note: fulfillment value of .immediate (the default value) means no delay in serving the response. A value of .delay(2) means, "introduce a 2 second delay before serving the response." A value of .never means do not ever serve the response and instead wait for the service call to timeout
    /// - parameter key: A SupportedURLOverrides value the determines the type of the web service to handle
    /// - parameter statusCode: The status code to be returned as part of the HTTPURLResponse
    /// - parameter value: Optional string value of the body of the HTTPURLResponse
    /// - parameter url: Optional URL to be included as part of the HTTPURLResponse
    /// - parameter headerFields: Optional header fields to be included as part of the HTTPURLResponse
    /// - parameter repeating: The number of times this response should be repeatedly served for a matching service call. Defaults to `.noRepeats`
    /// - parameter fullfillment: A `FulfillmentSchedule` value allowing for the introduction of delays before serving the response. The default value is .immediate meaning no delay.
    /// - throws URLProtocolMockError.couldNotCreateHTTPURLResponse if a HTTPURLResponse could not be created from the specified parameters
    ///
    public static func enqueueCustomStringResponse(
        key: SupportedURLOverrides,
        statusCode: Int,
        value: String?,
        url: URL? = nil,
        httpVersion: String? = nil,
        headerFields: [String: String]? = nil,
        repeating: RepeatingResponse = .noRepeats,
        fulfillment: FulfillmentSchedule = .immediate
    ) throws {
        try genericEnqueueCustomStringResponse(key: key.rawValue,
                                        statusCode: statusCode,
                                        value: value,
                                        url: url,
                                        httpVersion: httpVersion,
                                        headerFields: headerFields,
                                        repeating: repeating,
                                        fulfillment: fulfillment)
    }
    
    /// The intended user-facing method to provide a custom response including status code, dictionary based data, header fields, etc.
    /// 
    /// Suppose that you wanted to enqueue a response with a 405 status code and response body of "Method not allowed"
    /// ```swift
    /// let expectedValue = [
    ///    "key1": "val1",
    ///    "key2": "val2"
    /// ]
    ///
    /// try URLProtocolMock.enqueueCustomDictionaryResponse(
    ///     key: .item,
    ///     statusCode: 405,
    ///     value: expectedValue
    /// )
    /// ```
    ///
    /// - note: key, status code and value are the only required values.
    /// - note: fulfillment value of .immediate (the default value) means no delay in serving the response. A value of .delay(2) means, "introduce a 2 second delay before serving the response." A value of .never means do not ever serve the response and instead wait for the service call to timeout
    /// - parameter key: A SupportedURLOverrides value the determines the type of the web service to handle
    /// - parameter statusCode: The status code to be returned as part of the HTTPURLResponse
    /// - parameter value: Dictionary of [String: String] values to use as the HTTPURLResponse body
    /// - parameter url: Optional URL to be included as part of the HTTPURLResponse
    /// - parameter headerFields: Optional header fields to be included as part of the HTTPURLResponse
    /// - parameter repeating: The number of times this response should be repeatedly served for a matching service call. Defaults to `.noRepeats`
    /// - parameter fullfillment: A `FulfillmentSchedule` value allowing for the introduction of delays before serving the response. The default value is .immediate meaning no delay.
    /// - throws URLProtocolMockError.couldNotCreateHTTPURLResponse if a HTTPURLResponse could not be created from the specified parameters
    ///
    /// Add a custom dictionary response and status code  to be returned for web service calls utilizing the specified key
    /// Typical usage would be to provide, for example, a 405 status code with response body of a dictionary representing
    /// JSON values for a particular web service call
    public static func enqueueCustomDictionaryResponse(
        key: SupportedURLOverrides,
        statusCode: Int,
        value: [String: String],
        url: URL? = nil,
        httpVersion: String? = nil,
        headerFields: [String: String]? = nil,
        repeating: RepeatingResponse = .noRepeats,
        fulfillment: FulfillmentSchedule = .immediate
    ) throws {
        try genericEnqueueCustomDictionaryResponse(key: key.rawValue,
                                                   statusCode: statusCode,
                                                   value: value,
                                                   url: url,
                                                   httpVersion: httpVersion,
                                                   headerFields: headerFields,
                                                   repeating: repeating,
                                                   fulfillment: fulfillment)
    }
    
}

// MARK: Generic Enqueing Methods
extension URLProtocolMock {
    
    /// Generic form the enqueueStaticResponse method. Not intended to be called directly by testing methods.
    ///
    /// The generic methods are intended to be called from classes adopting `OverrideProtocol`. Those classes will define string-based "key" enumerations allowing testing code
    /// enqueue based on a key like `.item` rather than a plain string value.
    ///
    public static func genericEnqueueStaticResponse(key: String,
                                                    filename: String,
                                                    bundle: Bundle,
                                                    repeating: RepeatingResponse = .noRepeats,
                                                    fulfillment: FulfillmentSchedule = .immediate) {
        
        guard let data = self.dataFromFile(filename, in: bundle) else {
            return
        }
        
        let response = ResponseType.data(data, fulfillment)
        
        self.updateStaticResponses(for: key, response: response, repeating: repeating)
        
    }
    
    // Generic form the enqueueErrorResponse method. Not intended to be called directly by testing methods.
    ///
    /// The generic methods are intended to be called from classes adopting `OverrideProtocol`. Those classes will define string-based "key" enumerations allowing testing code
    /// enqueue based on a key like `.item` rather than a plain string value.
    ///
    public static func genericEnqueueErrorResponse(key: String,
                                                   error: Error,
                                                   repeating: RepeatingResponse = .noRepeats,
                                                   fulfillment: FulfillmentSchedule = .immediate) {
        
        let response = ResponseType.object(Result.failure(error), fulfillment)
        self.updateStaticResponses(for: key, response: response, repeating: repeating)
    }
    
    // Generic form the enqueueDataResponse method. Not intended to be called directly by testing methods.
    ///
    /// The generic methods are intended to be called from classes adopting `OverrideProtocol`. Those classes will define string-based "key" enumerations allowing testing code
    /// enqueue based on a key like `.item` rather than a plain string value.
    ///
    public static func genericEnqueueDataResponse<T: Encodable>(key: String,
                                                                object: T,
                                                                repeating: RepeatingResponse = .noRepeats,
                                                                fulfillment: FulfillmentSchedule = .immediate) {
        
        if let foundData = object as? Data {
            self.updateStaticResponses(for: key,
                                          response: ResponseType.data(foundData, fulfillment),
                                          repeating: repeating)
            return
        }
       
        guard let encoded = try? LibraryJSONEncoder().encode(object) else {
            return
        }
        let response = ResponseType.data(encoded, fulfillment)
        self.updateStaticResponses(for: key, response: response, repeating: repeating)
        
    }
    
    // Generic form the enqueueDownload method. Not intended to be called directly by testing methods.
    ///
    /// The generic methods are intended to be called from classes adopting `OverrideProtocol`. Those classes will define string-based "key" enumerations allowing testing code
    /// enqueue based on a key like `.item` rather than a plain string value.
    ///
    public static func genericEnqueueDownload(key: String,
                                              fileName: String,
                                              bundle: Bundle,
                                              repeating: RepeatingResponse = .noRepeats,
                                              fulfillment: FulfillmentSchedule = .immediate,
                                              statusCode: Int = 200,
                                              headers: [String: String] = [:]) throws {
        
        guard let data = self.dataFromFile(fileName, in: bundle) else {
            throw URLProtocolMockError.couldNotLoadDownloadFile(fileName)
        }
        
        if headers.isEmpty {
            let response = ResponseType.data(data, fulfillment)
            self.updateStaticResponses(for: key, response: response, repeating: repeating)
        } else {
            
            var newHeaders = headers
            newHeaders["Content-Disposition"] = "filename=\(fileName)"
            
            try genericEnqueueDataInHTTPURLResponse(
                key: key,
                statusCode: statusCode,
                data: data,
                url: nil,
                httpVersion: nil,
                headerFields: newHeaders,
                repeating: repeating,
                fulfillment: fulfillment
            )
        }
        
    }
    
    // Generic form the enqueueCustomStringResponse method. Not intended to be called directly by testing methods.
    ///
    /// The generic methods are intended to be called from classes adopting `OverrideProtocol`. Those classes will define string-based "key" enumerations allowing testing code
    /// enqueue based on a key like `.item` rather than a plain string value.
    ///
    public static func genericEnqueueCustomStringResponse(
        key: String,
        statusCode: Int,
        value: String?,
        url: URL? = nil,
        httpVersion: String? = nil,
        headerFields: [String: String]? = nil,
        repeating: RepeatingResponse = .noRepeats,
        fulfillment: FulfillmentSchedule = .immediate
    ) throws {
        
        let data = value?.data(using: .utf8)
        
        let url = url ?? URL(string: "http://www.foo.com")!
        
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
            ) else {
                throw URLProtocolMockError.couldNotCreateHTTPURLResponse
        }
        
        self.updateStaticResponses(
            for: key,
            response: ResponseType.customResponse(data, httpResponse, fulfillment),
            repeating: repeating
        )
        
    }
    
    // Not intended to be called directly by testing methods.
    ///
    /// The generic methods are intended to be called from classes adopting `OverrideProtocol`. Those classes will define string-based "key" enumerations allowing testing code
    /// enqueue based on a key like `.item` rather than a plain string value.
    ///
    internal static func genericEnqueueDataInHTTPURLResponse(
        key: String,
        statusCode: Int,
        data: Data,
        url: URL? = nil,
        httpVersion: String? = nil,
        headerFields: [String: String]? = nil,
        repeating: RepeatingResponse = .noRepeats,
        fulfillment: FulfillmentSchedule = .immediate
    ) throws {
        
        let url = url ?? URL(string: "http://www.foo.com")!
        
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
            ) else {
                throw URLProtocolMockError.couldNotCreateHTTPURLResponse
        }
        
        self.updateStaticResponses(
            for: key,
            response: ResponseType.customResponse(data, httpResponse, fulfillment),
            repeating: repeating
        )
        
    }
    
    // Generic form the enqueueCustomDictionaryResponse method. Not intended to be called directly by testing methods.
    ///
    /// The generic methods are intended to be called from classes adopting `OverrideProtocol`. Those classes will define string-based "key" enumerations allowing testing code
    /// enqueue based on a key like `.item` rather than a plain string value.
    ///
    public static func genericEnqueueCustomDictionaryResponse(
        key: String,
        statusCode: Int,
        value: [String: String],
        url: URL? = nil,
        httpVersion: String? = nil,
        headerFields: [String: String]? = nil,
        repeating: RepeatingResponse = .noRepeats,
        fulfillment: FulfillmentSchedule = .immediate
    ) throws {
        
        let data = try LibraryJSONEncoder().encode(value)
        
        let url = url ?? URL(string: "http://www.foo.com")!
        
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
            ) else {
                throw URLProtocolMockError.couldNotCreateHTTPURLResponse
        }
        
        self.updateStaticResponses(
            for: key,
            response: ResponseType.customResponse(data, httpResponse, fulfillment),
            repeating: repeating
        )
    }
}

/// Assist with override functionality from a common location
extension URLProtocolMock {
    
    /// Simple wrapper to assist in overriding URL behavior for unit tests
    /// - parameter url: Supply the URL you want CaasREST to return.
    /// - returns: Higher-order function of the type (() -> URL?)?. This represents the current closure in
    ///    CaaSREST which returns the baseURL. In order to override, we need to save this value off so that it
    ///    can later be passed into "reset".
    internal class func overrideBaseURL(url: URL? = nil) {
        // override the baseURL
        
        self.existingBaseURL = Onboarding.urlProvider?.url
        
        let foundURL = url ?? URL(string: "http://dummyhost:80")
        Onboarding.urlProvider?.url = { return foundURL }
    }
    
    /// Reset dependencies, restore the functionality of CaaSREST API to determine the baseURL and remove any (potentially) lingering static responses
    public class func reset() {
        
        Onboarding.reset()
    
        Onboarding.urlProvider = self.existingURLProvider
        Onboarding.sessions = self.existingSessionProvider ?? OracleContentSessionProvider()
        
        if let foundLoggingProvider = self.existingLoggingProvider {
            Onboarding.logger = foundLoggingProvider
        }
//        \Onboarding.logger = self.existingLoggingProvider
        Onboarding.urlProvider?.url = self.existingBaseURL ?? { nil }
        
        URLProtocolMock.staticResponses.removeAll()
        URLProtocolMock.repeatingResponses.removeAll()
        URLProtocolMock.additionalURLOverrides.removeAll()
    }
    
    /// Stores the data for the specified key
    /// - parameter key: The SupportedURLOverrides type representing the data
    /// - parameter response: The `ResponseType` enumeration with associated values representing the response to return
    /// - parameter repeating: The `RepeatingResponse` enumeration detailing whether the response should be reused for subsequent calls
    private static func updateStaticResponses(for key: String,
                                              response: ResponseType,
                                              repeating: RepeatingResponse) {
        
        self.repeatingResponses[key] = repeating
        
        // if no data exists for the specified key, add it and bail out
        guard let values = URLProtocolMock.staticResponses[key] else {
            URLProtocolMock.staticResponses[key] = [response]
            return
        }
        
        // if there's an empty array, add the data
        if values.isEmpty {
            URLProtocolMock.staticResponses[key] = [response]
        } else {
            // jump through some hoops to append the data to the existing values
            var updatedValues = values
            updatedValues.append(response)
            URLProtocolMock.staticResponses[key] = updatedValues
        }
        
    }
    
    /// Return data from the specified file
    /// - parameter filename: the name of the file. If no extension is provided, then "json" will be inferred
    /// - parameter bundle: The bundle in which the file is located. Defaults to .main
    /// - returns: Data?
    public static func dataFromFile(_ filename: String, in bundle: Bundle = .main) -> Data? {
    
        guard let url = try? Self.fileURLFromFile(filename, in: bundle) else {
            return nil
        }
        let data = try? Data(contentsOf: url)
        
        return data
    }
    
    public static func filePath(for filename: String, in bundle: Bundle = .main) throws -> String {
        // Use the pathExtension if it exists, otherwise default to "json"
        var fileExtension = (filename as NSString).pathExtension
        if fileExtension.isEmpty {
            fileExtension = "json"
        }
        
        let newFileName = (filename as NSString).deletingPathExtension
        
            // no file means no data
        guard let path = bundle.path(forResource: newFileName,
                                     ofType: fileExtension) else {
            throw OracleContentError.invalidURL("Could not obtain file path")
        }
        
        return path
    }
    
    public static func fileURLFromFile(_ filename: String, in bundle: Bundle = .main) throws -> URL {
        let path = try filePath(for: filename, in: bundle)
        
        let url = URL(fileURLWithPath: path)
        return url
    }
}

extension URLProtocolMock {
    
    private static func dropFirstResponse(for key: String) {
        if let values = URLProtocolMock.staticResponses[key],
           let repeatingResponse = self.repeatingResponses[key] {
    
            switch repeatingResponse {
            case .attempts(let attempts):
                switch attempts {
                case 0, 1:
                    self.repeatingResponses[key] = .none
                    let mutatingValues = Array(values.dropFirst())
                    URLProtocolMock.staticResponses[key] = mutatingValues

                default:
                    let newRepeatingResponse = URLProtocolMock.RepeatingResponse.attempts(attempts - 1)
                    self.repeatingResponses[key] = newRepeatingResponse
                }
            
            case .noRepeats:
                let mutatingValues = Array(values.dropFirst())
                URLProtocolMock.staticResponses[key] = mutatingValues
                
            case .infiniteRepeat:
                break
            }
        }
    }
    
    public static func errorResponse(key: String) -> (Error?, FulfillmentSchedule)? {
        guard let allResponsesForKey = URLProtocolMock.staticResponses[key],
            let foundResponse = allResponsesForKey.first,
            case let URLProtocolMock.ResponseType.object(value, fulfillment) = foundResponse,
            case let Result.failure(error) = value else {
                
                return nil
        }
        
        URLProtocolMock.dropFirstResponse(for: key)
        
        return (error, fulfillment)
    }
    
    public static func dataResponse(key: String) -> (Data?, FulfillmentSchedule)? {
        guard let allResponsesForKey = URLProtocolMock.staticResponses[key],
            let foundResponse = allResponsesForKey.first,
            case let URLProtocolMock.ResponseType.data(value, fulfillment) = foundResponse else {
                return nil
        }
        
        URLProtocolMock.dropFirstResponse(for: key)
        
        return (value, fulfillment)
    }
    
    public static func httpURLResponse(key: String) -> (Data?, HTTPURLResponse, FulfillmentSchedule)? {
        guard let allResponsesForKey = URLProtocolMock.staticResponses[key],
            let foundResponse = allResponsesForKey.first,
            case let URLProtocolMock.ResponseType.customResponse(data, urlResponse, fulfillment) = foundResponse else {
                return nil
        }
        
        URLProtocolMock.dropFirstResponse(for: key)
    
        return (data, urlResponse, fulfillment)
    }

}

extension URLProtocolMock {
    
    public enum LoadStaticDataError: Error {
        case unableToLoadContentType
        case unableToLoadContentItem
        case unableToCreateComposite
        case unableToReadDataFromFile
    }
    
    /// Retrieve a content type from the specified file name
    ///
    /// - Parameters:
    ///   - filename: file name of the static data for the content type
    ///   - file: auto-generated
    ///   - line: auto-generated
    /// - Returns: ContentType
    /// - Throws: ManagementAPIError
    public static func decodableObject<Element: Decodable>(from filename: String,
                                                           file: StaticString = #file,
                                                           line: UInt = #line) throws -> Element {
        let bundle = Bundle(for: self)
        
        guard let data = URLProtocolMock.dataFromFile(filename, in: bundle) else {
            throw LoadStaticDataError.unableToReadDataFromFile
        }
        
        let decoder = LibraryJSONDecoder()
        
        do {
            let element = try decoder.decode(Element.self, from: data)
            return element
        } catch let error {
            throw error
        }
    }
    
}

// MARK: Public Enumerations
extension URLProtocolMock {
    /// Errors that may be thrown as part of the mocking process
    public enum URLProtocolMockError: Error {
        case invalidSession
        case couldNotCreateHTTPURLResponse
        case couldNotLoadDownloadFile(String)
    }
    
    /// Enumeration detailing how many times an enqueued response should repeat
    ///
    /// See the enqueueing functions for example usage
    public enum RepeatingResponse {
        /// Serve one response only
        case noRepeats
        
        /// Continue serving the same response for every service call that matches
        case infiniteRepeat
        
        /// Serve a specified number of responses for the service call that matches
        case attempts(UInt)
    }
    
    /// Enumeration allowing for the introduction of delays in the fullfillment of a web service response.
    ///
    /// See the enqueueing functions for example usage
    public enum FulfillmentSchedule {
        
        /// Service will be fulfilled immediately
        case immediate
        
        /// Service will be fulfilled after the specified delay
        case delay(TimeInterval)
        
        /// Service will never be fulfilled, causing the web service to eventually timeout
        case never
        
        /// Return the optional seconds of time that a web service should be delayed before it is fulfilled
        internal func delayTime() -> Double? {
            switch self {
            case .immediate:
                // immediate means no delay
                return 0.0
            
            case .delay(let interval):
                return interval
                
            case .never:
                // never means we will return nil so that timeouts will ultimately occur
                return nil
            }
        }
    }
}

// MARK: Internal Enumerations
extension URLProtocolMock {
    /// Internal types detailing the type of response to be enqueued
    internal enum ResponseType {
        case customResponse(Data?, HTTPURLResponse, FulfillmentSchedule)
        case data(Data, FulfillmentSchedule)
        case object(Swift.Result<Any, Error>, FulfillmentSchedule)
    }
}
