// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/**
Protocol implementing composition-based polling of web services.
Determination about whether to continue or return from the web service calls is provided by passing
a closure to `pollWithoutParsing`

 */
public protocol ImplementsPollingWithoutParsing: BaseImplementation {
    
    /// The actual service object which performs the transport operations
    var service: BaseServiceTransport<Element>? { get set }
    
    func pollWithoutParsing(
        attempts: UInt?,
        isComplete: @escaping (Data?, URLResponse?) -> Bool,
        completion: @escaping (Swift.Result<(Data?, URLResponse?), Error>) -> Void
    )

    func pollWithoutParsing(
        attempts: UInt?,
        isComplete: @escaping (Data?, URLResponse?) -> Bool
    ) -> Future<(Data?, URLResponse?), Error>
    
    @available(iOS 15.0, *)
    func pollAsyncWithoutParsing(
        attempts: UInt?,
        isComplete: @escaping (Data?, URLResponse?) -> Bool
    ) async throws -> (Data?, URLResponse?)
    
}

extension ImplementsPollingWithoutParsing {
    public func pollWithoutParsing(
        attempts: UInt? = nil,
        isComplete: @escaping (Data?, URLResponse?) -> Bool,
        completion: @escaping (Swift.Result<(Data?, URLResponse?), Error>) -> Void
    ) {
            guard self.serviceParameters.isWellFormed() else {
                completion(.failure(self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL("")))
                return
            }

            let service = BaseServiceTransport<Element>(self.serviceParameters.overrideSessionConfiguration,
                                                        useNoCacheSession: self.serviceParameters.useNoCacheSession)
            self.service = service

            guard let request = self.serviceParameters.request() else {
                completion(.failure(OracleContentError.invalidRequest))
                return
            }
    
            self.retryNoParsing(
                attempts: attempts,
                task: { result in
                    self.service?.performFetchNoParse(for: request) { serviceResult in
                        
                        switch serviceResult {
                        case .failure:
                            result(serviceResult)
                            
                        case .success(let resultTuple):
                            let (data, response) = resultTuple
                            if isComplete(data, response) {
                                result(serviceResult)
                            } else {
                                result( Result.failure(OracleContentCore.OracleContentError.pollingNotCompleted))
                            }
                        }
                    }
                    
                },
                completion: { finalResult in
                    completion(finalResult)
                }
            )
        }

    public func pollWithoutParsing(
        attempts: UInt? = nil,
        isComplete: @escaping (Data?, URLResponse?) -> Bool
    ) -> Future<(Data?, URLResponse?), Error> {

        return Future<(Data?, URLResponse?), Error> { promise in
            self.pollWithoutParsing(attempts: attempts, isComplete: isComplete) { result in
                promise(result)
            }
        }
    }
    
    private func retryNoParsing(
         attempts: UInt?,
         task: @escaping (_ completion: @escaping (Result<(Data?, URLResponse?), Error>) -> Void) -> Void,
         completion: @escaping (Result<(Data?, URLResponse?), Error>) -> Void
    ) {

         task { result in
             switch result {
             case .success:
                 completion(result)
                 
             case .failure(let error):
                
                switch self.shouldRetry(attempts: attempts, error: error) {
                case .failure:
                    completion(result)
                    
                case .success(let newAttempts):
                    self.retryNoParsing(attempts: newAttempts, task: task, completion: completion)
                }
                
             }
         }
     }
    
    /// Determine whether a retry attempt should be performed
    /// In order to retry, we need one of the following conditions to hold true:
    ///     - attempts is nil and error == .pollingNotCompleted
    ///     - attempts > 1 and error == .pollingNotCompleted
    private func shouldRetry(attempts: UInt?, error: Error) -> Result<UInt?, Error> {
    
        /// If our error is NOT .pollingNotCompleted then we have a "real" error
        /// This is enough to short-ciruit the polling process
        guard case OracleContentError.pollingNotCompleted = error else {
            return Result.failure(error)
        }
        
        if let attempts = attempts {
            
            if attempts > 1 {
                return Result.success(attempts - 1)
            } else {
                return Result.failure(error)
            }
            
        } else {
            return Result.success(nil)
        }
    }
}

// MARK: Swift Concurrency
@available(iOS 15.0, *)
extension ImplementsPollingWithoutParsing {
 
    public func pollAsyncWithoutParsing(
        attempts: UInt?,
        isComplete: @escaping (Data?, URLResponse?) -> Bool
    ) async throws -> (Data?, URLResponse?) {
        
        try await withUnsafeThrowingContinuation { continuation in
            self.pollWithoutParsing(attempts: attempts, isComplete: isComplete) { result in
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
