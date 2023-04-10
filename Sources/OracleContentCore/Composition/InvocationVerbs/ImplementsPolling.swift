// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
/**
Protocol implementing composition-based polling of web services.
Generic over `Element` which must conform to both `Decodable` and `SupportsPolling` protocols

Polling may be called with either a maximum number of attempts to try, OR
Polling may be called with an infinite number of attempts.
 
NOTE: If you choose to perform infinite polling, then it is caller's responsibility to include a .timeout
 operator in the Combine pipeline.

 */
public protocol ImplementsPolling: BaseImplementation where Element: SupportsPolling {
    
    /** The actual service object which performs the transport operations
      :nodoc:
    */
    var service: BaseServiceTransport<Element>? { get set }

    /** Continue submitting a web service call until it is either "complete", as determined by
     `Element`'s implementation of `SupportsPolling` or the maximum number of retry attempts have
     been submitted.
    
     - parameter attempts: UInt value determining the number of retry attempts to make before completing
     - parameter completion: Completion handler called when the service finishes with or without error
     
    ### Sample Poll With Maximum of 3 Attempts
      ```
      ManagementAPI
          .pollForWorkflowStatus(url: someURL)
          .poll(attempts: 3) { result in
             // handle result
          }
    
      ```
     */
    func poll(attempts: UInt?, completion: @escaping (Swift.Result<Element, Error>) -> Void)
    
    /** Continue submitting a web service call until it is either "complete", as determined by
     `Element`'s implementation of `SupportsPolling` or the maximum number of retry attempts have
     been submitted.
     - parameter attempts: UInt value determining the number of retry attempts to make before completing
    
    ### Sample Poll with Infinite Attempts and Timeout
     ```
     let cancellable =  ManagementAPI
                         .pollForWorkflowStatus(url: dummyURL)
                         .poll(attempts: nil)
                         .timeout(5, scheduler: DispatchQueue.main, customError: { () -> Error in
                             return someError
                         })
     ```
     */
    func poll(attempts: UInt?) -> Future<Element, Error>
    
    /** Poll using Swift concurrency.
    Continue submitting a web service call until it is either "complete", as determined by
    `Element`'s implementation of `SupportsPolling` or the maximum number of retry attempts have
    been submitted.

    - requires: iOS 15.0
    - parameter attempts: UInt value determining the number of retry attempts to make before completing

    ### Sample Poll with Infinite Attempts and Timeout
    ```
        let result = await ManagementAPI
                            .pollForWorkflowStatus(url: dummyURL)
                            .poll(attempts: nil, seconds: 30)
    ```
    */
    @available(iOS 15.0, *)
    func pollAsync(attempts: UInt?, seconds: TimeInterval?) async throws -> Element

}

extension ImplementsPolling {
    public func poll(
        attempts: UInt?,
        completion: @escaping (Result<Element, Error>) -> Void
    ) {
        
        guard self.serviceParameters.isWellFormed() else {
            completion(.failure(self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL("")))
            return
        }
        
        let service = BaseServiceTransport<Element>(self.serviceParameters.overrideSessionConfiguration,
                                                    useNoCacheSession: self.serviceParameters.useNoCacheSession)
        self.service = service
        let request = self.serviceParameters.request()
        
        self.retry(
            attempts: attempts,
            task: { result in
                
                self.service?.fetchDetail(request: request) { serviceResult in
                    
                    switch serviceResult {
                    case .failure:
                        result(serviceResult)
                        
                    case .success(let value):
                        if value.isComplete() {
                            result(serviceResult)
                        } else {
                            result( Result<Element, Error>.failure(OracleContentCore.OracleContentError.pollingNotCompleted))
                        }
                    }
                }
            },
            completion: { finalResult in
                completion(finalResult)
            }
        )
    }
    
    public func poll(attempts: UInt?) -> Future<Element, Error> {
        
        return Future<Element, Error> { promise in
            self.poll(attempts: attempts) { result in
                promise(result)
            }
        }
    }
    
    func retry(
        attempts: UInt?,
        task: @escaping (_ completion: @escaping (Result<Element, Error>) -> Void) -> Void,
        completion: @escaping (Result<Element, Error>) -> Void
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.retry(attempts: newAttempts, task: task, completion: completion)
                    }
                    
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

// MARK: iOS 15
@available(iOS 15.0, *)
extension ImplementsPolling {

    public func pollAsync(attempts: UInt?, seconds: TimeInterval?) async throws -> Element {
        
        try await withUnsafeThrowingContinuation { continuation in
            
            let c = self.poll(attempts: attempts)
        
            var cancellable: AnyCancellable?
            
            if let foundSeconds = seconds {
               cancellable = c
                    .timeout(.seconds(foundSeconds), scheduler: DispatchQueue.main, customError: { () -> Error in
                        OracleContentError.pollingNotCompleted
                        
                    })
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            continuation.resume(throwing: error)
                            
                        default:
                            break
                        }
                        cancellable?.cancel()
                        cancellable = nil
                        
                    }, receiveValue: { element in
                        continuation.resume(returning: element)
                    })
            } else {
                _ =  self.poll(attempts: attempts)
                     .sink(receiveCompletion: { completion in
                         switch completion {
                         case .failure(let error):
                             continuation.resume(throwing: error)
                             
                         default:
                             break
                         }

                     }, receiveValue: { element in
                         continuation.resume(returning: element)
                     })
            }
        }
    }
}

