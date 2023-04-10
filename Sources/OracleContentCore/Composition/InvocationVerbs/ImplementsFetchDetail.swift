// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/**
 Allows a conforming service to retrieve detail information about an asset through various **fetch** invocation verbs
*/
public protocol ImplementsFetchDetail: BaseImplementation {
    
    /// The actual service object which performs the transport operations
    var service: BaseServiceTransport<Element>? { get set }
    
    /// Add a parameter to the web service. Provided so that objects conforming to this protocol can pass along necessary
    ///  parameter values to the underlying download service
    /// - parameter key: the key of the parameter to add
    /// - parameter value: the value of the parameter
    func addParameter(key: String, value: ConvertToURLQueryItem)
    
    /// Fetch the detailed information for a specified asset using a completion handler
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func fetch(completion: @escaping (Swift.Result<Element, Error>) -> Void)
    
    /// Fetch the detailed information for a specified asset using a Future.
    /// - returns: Future<Element, Error>
    func fetch() -> Future<Element, Error>
    
    /// Fetch the detailed information for a specified asset using a completion handler. This invocation verb will not parse results into a model object,
    /// but instead will return the raw data and response to the caller.
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func fetchWithoutParsing(completion: @escaping (Swift.Result<(Data?, URLResponse?), Error>) -> Void)
    
    /// Execute the data task and return the raw Data, URLResponse and/or Error
    /// It is the responsibility of the caller to interrogate the values returned
    ///  - parameter completion: Completion handler called when the service finishes with or without error
    func fetchAsDataTask(completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    
    /// Fetch the detailed information for a specified asset using Swift concurrency.
    /// - requires: iOS 15.0
    /// - returns: Element
    @available(iOS 15.0, *)
    func fetchAsync() async throws -> Element

}

extension ImplementsFetchDetail {
    public func fetch(completion: @escaping (Result<Element, Error>) -> Void) {
        
        guard self.serviceParameters.isWellFormed() else {
            completion(.failure(self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL("")))
            return
        }
        
        let service = BaseServiceTransport<Element>(self.serviceParameters.overrideSessionConfiguration,
                                          useNoCacheSession: self.serviceParameters.useNoCacheSession)
        self.service = service
        let request = self.serviceParameters.request()
        service.fetchDetail(request: request) { result in
            
            completion(result)
        }
        
    }
    
    public func fetch() -> Future<Element, Error> {
        
        return Future<Element, Error> { promise in
            self.fetch(completion: promise)
        }
    }
    
    public func fetchWithoutParsing(completion: @escaping (Swift.Result<(Data?, URLResponse?), Error>) -> Void) {
        
        guard self.serviceParameters.isWellFormed() else {
            completion(.failure(self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL("")))
            return
        }
        
        guard let request = self.serviceParameters.request() else {
            completion(.failure(OracleContentError.invalidRequest))
            return
        }
        
        let service = BaseServiceTransport<Element>(self.serviceParameters.overrideSessionConfiguration,
                                                    useNoCacheSession: self.serviceParameters.useNoCacheSession)
        self.service = service
        
        service.performFetchNoParse(for: request, completion: completion)
    }
    
    public func fetchWithoutParsing() -> Future<(Data?, URLResponse?), Error> {
        return Future<(Data?, URLResponse?), Error> { promise in
            self.fetchWithoutParsing(completion: promise)
        }
    }
}

// MARK: Swift Concurrency
@available(iOS 15.0, *)
extension ImplementsFetchDetail {
    /// Async implementation of fetch
    /// - returns: Result<Element, Error>
    public func fetchAsync() async throws -> Element {
        try await withUnsafeThrowingContinuation { continuation in
            self.fetch { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                    
                case .success(let value):
                    continuation.resume(returning: value)
                }
            }
        }
    }
    
    public func fetchWithoutParsing() async throws -> (Data?, URLResponse?) {
        try await withUnsafeThrowingContinuation { continuation in
            self.fetchWithoutParsing { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension ImplementsFetchDetail {
    public func fetchAsDataTask(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard self.serviceParameters.isWellFormed() else {
            completion(nil, nil, self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL(""))
            return
        }
        
        guard let request = self.serviceParameters.request() else {
            completion(nil, nil, OracleContentError.invalidRequest)
            return
        }
        
        let service = BaseServiceTransport<Element>(self.serviceParameters.overrideSessionConfiguration,
                                                    useNoCacheSession: self.serviceParameters.useNoCacheSession)
        self.service = service
        
        self.service?.performDataTaskNoParse(for: request, completion: completion)
    }
}
