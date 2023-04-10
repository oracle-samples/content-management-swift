// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/**
 Structure defining the values that present for "listing" services.
 This structure is provided so that responses can be tested for the presence of these specific values
 */
public struct ListingCountValues: Decodable {
    public var hasMore: Bool
    public var offset: UInt
    public var count: UInt
    public var totalResults: UInt?
}

/// This is the object responsible for making all non-download HTTP requests
/// It is generic over `Element`, a decodable object into which the raw response will be decoded
///
public class BaseServiceTransport<Element: Decodable>: SupportsCancel {

    /// URLSession used for fetching data
    internal var session: URLSession?
    
    /// URLSessionConfiguration used for fetching data
    internal var sessionConfiguration: URLSessionConfiguration?
    
    /// An unique identifier that can be used to track this particular web service throughout debugging, logs, collections, etc.
    internal var serviceIdentifier: String = UUID().uuidString
    
    /// Data task used to perform the actual web service call
    internal var dataTask: URLSessionDataTask?
    
    /// URL to be submitted
    internal var url: URL?
    
    /// Determines which session object to use
    internal var useCache = false
    
    /// Determines the type of request (GET, POST, PUT, DELETE) to execute
    internal let requestType: RequestType?
    
    /// Optional POST body to use for the request
    internal var postBody: String?
    
    /// Property indicating whether a web service call is expected to return additional data if called again
    /// This property is only useful for web services that perform "listing" requests as those services are typically called
    /// by specifying "offset" and "limit" values.
    /// If a listing service is called with offset = 0 and limit = 5, but the web service returns that 100 records exist in total,
    /// then the `hasMore` property will be true.
    ///
    /// On the other hand, if a listing service is called with offset = 0 and limit = 100, but only 5 records exist in total,
    /// the the `hasMore` property will be false.
    ///
    /// Finally, the `hasMore` property will be false after calling a web service designed to retrieve "detail" information for
    /// a single object.
    internal var hasMore = true
    
    public var cancellables = [AnyCancellable]()
    
    public var customErrorHandler: ((Data) -> Error?)?
    
    /// Cancel the web service
    public func cancel() {
        self.dataTask?.cancel()
    }
    
    /// Initializer of the class used to actually execute web service requests
    /// - Parameters:
    ///   - sessionConfiguration: Optional override URLSessionConfiguration. If specified, it will be used to build the URLSession used by the service
    ///   - useNoCacheSession: Pass false to allow the service to utilize cached values. Pass true for the service to bypass cached values
    public init(
        _ sessionConfiguration: URLSessionConfiguration? = nil,
        useNoCacheSession: Bool = false
    ) {
        self.useCache = useNoCacheSession
        self.requestType = nil
        self.sessionConfiguration = sessionConfiguration
    }
}

// MARK: Listing
extension BaseServiceTransport {
    
    /// Closure-based fetch of a listing
    /// - parameter request: `URLRequest` to submit
    /// - parameter completion: Callback performed when the web service completes
    /// - parameter update: Optional closure of the form (ListingCountValues?) -> Void. This closure is used so that the `hasMore` property can be
    ///   updated following web service completion.
    public func fetchListing(request: URLRequest?,
                             completion: @escaping(Result<Element, Error>) -> Void,
                             update: ((ListingCountValues?) -> Void)? = nil) {
        
        self.internalFetch(request: request) { result in
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let items):
                let foundHasMore = items.1
                update?(foundHasMore)
                completion(.success(items.0))
            }
        }
    }
    
    /// Fetch a listing using Combine.
    /// - parameter request: `URLRequest` to submit
    /// - parameter update: Optional closure of the form (ListingCountValues?) -> Void. This closure is used so that the `hasMore` property can be
    ///   updated following web service completion.
    /// - returns: Future<Element, Error>
    public func fetchListing(
        request: URLRequest?,
        update: ((ListingCountValues?) -> Void)? = nil
    ) -> Future<Element, Error> {
        
        Future<Element, Error> { [weak self] promise in
            
            self?.fetchListing(
                request: request,
                completion: promise,
                update: update
            )
        }
     }
}

// MARK: Detail
extension BaseServiceTransport {
    
    /// Closure-based fetch of detailed information about an asset
    /// - parameter request: `URLRequest` to submit
    /// - parameter completion: Callback performed when the web service completes
    public func fetchDetail(
        request: URLRequest?,
        completion: @escaping (Result<Element, Error>) -> Void
    ) {
        self.fetchListing(request: request, completion: completion, update: nil)
     }
     
    /// Fetch detail information using Combine. 
    /// - parameter request: `URLRequest` to submit
    /// - returns: Future<Element, Error>
     public func fetchDetail(request: URLRequest?) -> Future<Element, Error> {
         
         return fetchListing(request: request, update: nil)
     }
}

// MARK: Raw Fetch
extension BaseServiceTransport {
    
    public func performFetchNoParse (
        for request: URLRequest,
        completion: @escaping (Result<(Data?, URLResponse?), Error>) -> Void
    ) {
        
        self.performDataTaskNoParse(for: request) { data, response, error in
            
            let result = ResultFromResponse.result(data: data, response: response, error: error)
            
            switch result {
            case .failure(let error):
                Onboarding.logError("Unable to fetch data. URLRequest is invalid")
                completion(.failure(error))
                
            case .success(let successValues):
                completion(.success(successValues))
            }
            
            return
        }
    }
    
    /// Execute the web service without parsing results into a decodable structure
    /// - parameter for: `URLRequest` to execute
    /// - parameter completion: Callback performed when the web service completes
    public func performDataTaskNoParse(
        for request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        
        guard let session = self.urlSessionForFetch() else {
            Onboarding.logError("Unable to fetch data. URLRequest is invalid")
            completion(nil, nil, OracleContentError.invalidURLSession)
            return
        }
        
        Onboarding.logNetworkRequest(request, session: self.session)
        
        self.dataTask = session.dataTask(with: request) { data, response, error in
            
            Onboarding.logNetworkResponseWithData(response as? HTTPURLResponse, data: data)
            completion(data, response, error)
        }
        
        // Execute the web service call
        self.dataTask?.resume()
        
    }
}

// MARK: Private fetch code
extension BaseServiceTransport {

    /// Private function responsible for calling the actual HTTP transport and then decoding the raw response
    private func internalFetch(
        request: URLRequest?,
        completion: @escaping(Result<(Element, ListingCountValues?), Error>) -> Void
    ) {
        guard let urlRequest = request else {
            Onboarding.logError("Unable to fetch data. URLRequest is invalid")
            completion(.failure(OracleContentError.invalidRequest))
            return
        }
        
        /// Execute the web service, calling the completion closure when done
        self.performFetchNoParse(for: urlRequest) { result in
            switch result {
            case .success(let values):
                let (data, _) = values
                
                guard let foundData = data else {
                    completion(Result.failure(OracleContentError.invalidDataReturned))
                    return
                }
                
                do {
                    let decoder = LibraryJSONDecoder()
                    let decodedData = try decoder.decode(Element.self, from: foundData)
                    let listingCountValues = try? decoder.decode(ListingCountValues.self, from: foundData)
                    completion(Result.success((decodedData, listingCountValues)))
                   
                } catch {
                    
                    // Handle conversation-specific error 
                    if let foundError = self.customErrorHandler?(foundData) {
                        completion(Result.failure(foundError))
                        return
                    }
                    Onboarding.logError("Failed to decode service response. Error: \(error.localizedDescription)")
                    completion(Result.failure(error))
                }
                
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    /// Determine which URLSession to use for the service
    private func urlSessionForFetch() -> URLSession? {
        
        if let foundConfig = self.sessionConfiguration {
            self.session = URLSession(configuration: foundConfig)
        } else {
            if self.useCache {
                self.session = Onboarding.sessions.session()
            } else {
                self.session = Onboarding.sessions.noCacheSession()
            }
        }
        
        return self.session
    }
}
