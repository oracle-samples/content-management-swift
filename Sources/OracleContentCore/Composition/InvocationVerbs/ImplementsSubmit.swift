// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
/**
Protocol implementing composition-based submission of asset action services
Any object which conforms to this protocol will have the ability to execute web service calls  for objects defined in the `serviceParameters` property.

By providing this capability, we eliminate the need for lots of duplicate code. Uptake is exceptionally simple - conform to the protocol
 by providing  `service` and `serviceParameters` and you have the ability to call '`submit` methods

 */
public protocol ImplementsSubmit: BaseImplementation {
    
    /// The actual service object which performs the transport operations
    var service: BaseServiceTransport<Element>? { get set }
    
    ///Submit the web service call using a completion handler
    ///
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func submit(completion: @escaping (Swift.Result<Element, Error>) -> Void)
    
    ///Submit the web service call using a Future.
    ///
    /// - returns: Future<Element, Error>
    func submit() -> Future<Element, Error>
    
    /// Execute the data task and return the raw Data, URLResponse and/or Error
    /// It is the responsibility of the caller to interrogate the values returned
    ///  - parameter completion: Completion handler called when the service finishes with or without error
    func submitAsDataTask(completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    
    ///Submit the web service call using Swift Concurrency. Requires iOS 15+
    /// - requires: iOS 15.0
    /// - returns: Element
    @available(iOS 15.0, *)
    func submitAsync() async throws -> Element

}

extension ImplementsSubmit {
    public typealias ServiceElement = Element
    
    public func submit(completion: @escaping (Result<Element, Error>) -> Void) {
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
    
    public func submit() -> Future<Element, Error> {
        guard self.serviceParameters.isWellFormed() else {
            return Future<Element, Error> { promise in
                promise(.failure(self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL("")))
            }
        }

        let service = BaseServiceTransport<Element>(self.serviceParameters.overrideSessionConfiguration,
                                                    useNoCacheSession: self.serviceParameters.useNoCacheSession)
        let request = self.serviceParameters.request()
        self.service = service
        
        return service.fetchDetail(request: request)
    }
    
    public func submitWithoutParsing(completion: @escaping (Swift.Result<(Data?, URLResponse?), Error>) -> Void) {
        
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
    
    public func submitWithoutParsing() -> Future<(Data?, URLResponse?), Error> {
        return Future<(Data?, URLResponse?), Error> { promise in
            self.submitWithoutParsing { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                    
                case .success(let successValue):
                    promise(.success(successValue))
                }
            }
        }
    }
    
    public func submitAsDataTask(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
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
        
        service.performDataTaskNoParse(for: request, completion: completion)
    }
    
}

// MARK: Swift Concurrency
@available(iOS 15.0, *)
extension ImplementsSubmit {
    
    public func submitAsync() async throws -> Element {
        try await withUnsafeThrowingContinuation { continuation in
            self.submit { result in
                switch result {
                case .success(let val):
                    continuation.resume(returning: val)
    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func submitAsyncWithoutParsing() async throws -> (Data?, URLResponse?) {
        
        try await withUnsafeThrowingContinuation { continuation in
            self.submitWithoutParsing { result in
                switch result {
                case .success(let val):
                    continuation.resume(returning: val)
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
