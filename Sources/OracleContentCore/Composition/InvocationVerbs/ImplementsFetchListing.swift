// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/**
 Allows a conforming service to retrieve a listing of assets through various **fetchNext** invocation verbs. **FetchNext** will automatically update the **hasMore** and **offset** values upon completion, thereby allowing callers to continue calling the same service to retrieve the "next" set of data.
*/
public protocol ImplementsFetchListing: BaseImplementation {
    
    /// The actual service object which performs the transport operations
    var service: BaseServiceTransport<Element>? { get set }

    /// Add a parameter to the web service. Provided so that objects conforming to this protocol can pass along necessary
    ///  parameter values to the underlying download service
    /// - parameter key: the key of the parameter to add
    /// - parameter value: the value of the parameter
    func addParameter(key: String, value: ConvertToURLQueryItem)
    
    /// Fetch the next set of asset listings  using a completion handler
    /// The "next" set of listings is determined by the conforming object.
    /// Typically, conforming web service objects will implement (at least) the ability to specify "offset" and "limit" values.
    ///
    /// For example, the service to search assets conforms to the protocol.  That service provides the following methods:
    /// `public func starting(at offset: UInt) -> SearchAssets`
    /// `public func limit(_ max: UInt) -> SearchAssets`
    /// Each conforming web service can determine its own set of default values. but the common practice is to allow callers
    /// to modify those values through methods such as theses
    ///
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func fetchNext(completion: @escaping (Swift.Result<Element, Error>) -> Void)
    
    /// Fetch the next set of asset listings  using a Future. 
    /// The "next" set of listings is determined by the conforming object.
    /// Typically, conforming web service objects will implement (at least) the ability to specify "offset" and "limit" values.
    ///
    /// For example, the service to search assets conforms to the protocol.  That service provides the following methods:
    /// ```
    /// public func starting(at offset: UInt) -> SearchAssets
    /// public func limit(_ max: UInt) -> SearchAssets
    /// ```
    /// Each conforming web service can determine its own set of default values. but the common practice is to allow callers
    /// to modify those values through methods such as these
    ///
    /// - returns: Future<Element, Error>
    func fetchNext() -> Future<Element, Error>
    
    /// Fetch the next set of asset listings using Swift concurrency. Requires iOS 15.0 or greater
    /// The "next" set of listings is determined by the conforming object.
    /// Typically, conforming web service objects will implement (at least) the ability to specify "offset" and "limit" values.
    ///
    /// For example, the service to search assets conforms to the protocol.  That service provides the following methods:
    /// ```
    /// public func starting(at offset: UInt) -> SearchAssets
    /// public func limit(_ max: UInt) -> SearchAssets
    /// ```
    /// Each conforming web service can determine its own set of default values. but the common practice is to allow callers
    /// to modify those values through methods such as these
    /// - requires: iOS 15.0
    /// - returns: Element
    /// - throws: Error
    @available(iOS 15.0, *)
    func fetchNextAsync() async throws -> Element
    
    /// Fetch the next set of asset listings  using a completion handler. This invocation verb will not parse results into a model object,
    /// but instead will return the raw data and response to the caller.
    /// 
    /// The "next" set of listings is determined by the conforming object.
    /// Typically, conforming web service objects will implement (at least) the ability to specify "offset" and "limit" values.
    ///
    /// For example, the service to search assets conforms to the protocol.  That service provides the following methods:
    /// `public func starting(at offset: UInt) -> SearchAssets`
    /// `public func limit(_ max: UInt) -> SearchAssets`
    /// Each conforming web service can determine its own set of default values. but the common practice is to allow callers
    /// to modify those values through methods such as theses
    ///
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func fetchNextWithoutParsing(completion: @escaping (Swift.Result<(Data?, URLResponse?), Error>) -> Void)

    /// Execute the data task and return the raw Data, URLResponse and/or Error
    /// It is the responsibility of the caller to interrogate the values returned
    ///  - parameter completion: Completion handler called when the service finishes with or without error
    func fetchNextAsDataTask(completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    
    /**
    Specify the zero-based starting point of the assets listing.
    Initial calls should be made using an offset of zero.
    - parameter at: The first index to inclue in results.
    - returns: `ListAssets`
     */
    func starting(at offset: UInt) -> Self
    
    /**
    Determines the maximum number of assets to fetch at a time.
     
    - parameter max: Specify the number of repositories to fetch.
     
    Passing a value of zero will allow for counting the number of responses available, but will not fetch any of those assets
    - returns: `ListAssets`
     */
    func limit(_ max: UInt) -> Self
    
}

// MARK: Base Implmentation
extension ImplementsFetchListing {
    
    public func fetchNext(completion: @escaping (Swift.Result<Element, Error>) -> Void) {
        guard self.serviceParameters.hasMore == true else {
            completion(Result.failure(OracleContentError.noMoreData))
            return
        }
        
        guard self.serviceParameters.isWellFormed() else {
            completion(Result.failure(self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL("")))
            return
        }
 
        let service = BaseServiceTransport<Element>(self.serviceParameters.overrideSessionConfiguration,
                                                    useNoCacheSession: self.serviceParameters.useNoCacheSession)
        self.service = service
        let request = self.serviceParameters.request()
        service.fetchListing(request: request, completion: completion) { counts in
            guard let foundListingCounts = counts else {
                return
            }
            self.serviceParameters.hasMore = foundListingCounts.hasMore
            
            self.updateOffsetValues(newCount: foundListingCounts.count)
            
        }
    }
    
    public func fetchNext() -> Future<Element, Error> {
        
        return Future { promise in
            self.fetchNext(completion: promise)
        }
    }
    
     public func fetchNextWithoutParsing(completion: @escaping (Swift.Result<(Data?, URLResponse?), Error>) -> Void) {
         guard self.serviceParameters.hasMore == true else {
             completion(Result.failure(OracleContentError.noMoreData))
             return
         }
         
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

    public func starting(at offset: UInt) -> Self {
        let offset = OffsetParameter.value(offset)
        self.addParameter(key: OffsetParameter.keyValue, value: offset)
        return self
    }
    
    public func limit(_ max: UInt) -> Self {
        let limit = LimitParameter.value(max)
        self.addParameter(key: LimitParameter.keyValue, value: limit)
        return self
    }
    
}

extension ImplementsFetchListing {
    private func updateOffsetValues(newCount: UInt) {
        var existingOffset: UInt = 0
          
          switch self.serviceParameters.parameters[OffsetParameter.keyValue] {
          case .none:
              self.addParameter(key: OffsetParameter.keyValue, value: OffsetParameter.value(newCount))
              
          case .some(let queryItem):
              
             existingOffset = UInt(queryItem.queryItem?.value ?? "0") ?? 0
            
             self.addParameter(key: OffsetParameter.keyValue, value: OffsetParameter.value(newCount + existingOffset))
        
          }
    }
}

// MARK: Swift Concurrency
@available(iOS 15.0, *)
extension ImplementsFetchListing {
    
    public func fetchNextAsync() async throws -> Element {
        try await withUnsafeThrowingContinuation { continuation in
            self.fetchNext { result in
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

extension ImplementsFetchListing {

    public func fetchNextAsDataTask(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard self.serviceParameters.hasMore == true else {
            completion(nil, nil, OracleContentError.noMoreData)
            return
        }
        
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
