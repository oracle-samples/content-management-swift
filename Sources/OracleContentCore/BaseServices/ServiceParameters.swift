// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// swiftlint:disable conditional_returns_on_newline
import Foundation

/// Common class used to identify the parameters necessary to make Oracle Content requests
open class ServiceParameters {

    /// Will determine whether a web service is expected to have more data after it has been called
    public var hasMore = true
    
    /// Optional override URL. Normally the URL is determined by constants values defined in the onboarding process.
    /// This property allows that constant value to be overridden
    public var overrideURL: URL?
    
    /// Stores a function that will return any overridden header values to be used as part of a request.
    public var overrideURLRequestHeaders: ProvidesURLRequestHeaders?
    
    /// Optional override URLSessionConfiguration. Normally the URLSessionConfiguration is determined by constants value defined in the onboarding process.
    /// This property allows that constant value to be overridden
    public var overrideSessionConfiguration: URLSessionConfiguration?
    
    /// Optional override to force either the "cache" or "no cache" session
    public var overrideSession: URLSession?
    
    /// Optional override channel token. Used only by Delivery SDK
    public var overrideChannelToken: String?
    
    /// Dictionary of key, value pairs that determine the parameters of the web service URL
    public var parameters: [String: ConvertToURLQueryItem] = [:]
    
    /// The API version to use for this web service call. This will typically only be overridden for temporary development while
    /// servers are undergoing rolling upgrades
    public var apiVersion: APIVersion = LibraryPathConstants.currentAPIVersion
    
    /// The type of request (GET, POST, PUT, DELETE) to execute
    public var actionType: RequestType = .get
    
    /// Determines whether the authentication header must be applied to the request.
    public var includeAuthenticationHeader = false
    
    /// This will detemine whether the SDK call is a Management SDK or Delivery SDK call
    /// It's value is provided by the service being executed.
    /// For example, a provided value may look like "/content/management/api"'
    public var basePath: String = ""
    
    /// If set to true, the service will bypass the use of cached values
    public var useNoCacheSession = false
    
    /// The error to return when a service call is not well-formed   
    public var invalidURLError: Error?
    
    public var cacheProvider: CacheProvider?
    
    public var imageProvider: ImageProvider?
    
    public var cacheKey: String?
    
    public var additionalHeaderValues: [String: String] = [:]
    
    /// The primary determinant of the particular web service call
    /// Each web service will provide a value for this property. For example, services may set this value to "items", "item", "collections", "repositories", etc
    open var serviceSuffix: String { "uninitialized" }
    
    public init() {
    }
    
    /// The default (GET) request to be submitted
    open func request() -> URLRequest? {
        guard let url = self.buildURL() else { return nil }
        
        var request = Onboarding.getRequest(
            for: url,
            includeAuthenticationHeader: self.includeAuthenticationHeader,
            authHeaderProvider: self.overrideURLRequestHeaders
        )
        
        self.additionalHeaderValues.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    open func request(completion: @escaping (URLRequest?) -> Void) {
        guard let url = self.buildURL() else {
            completion(nil)
            return
        }
        
        var request =  Onboarding.getRequest(for: url,
                                             includeAuthenticationHeader: self.includeAuthenticationHeader,
                                             authHeaderProvider: self.overrideURLRequestHeaders)
        
        self.additionalHeaderValues.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        completion(request)
        
    }
    
    /// Each web service will override this implementation with logic to determine whether a request is well-formed
    /// This is typically done by ensuring that all necessary values are non-nil/non-blank and that any string formatting has been performed
    open func isWellFormed() -> Bool {
        return true
    }
    
    /// Web services designed to be submitted as POST requests will override this function to provide a formatted POST body
    open func postBody() throws -> String? {
        return nil
    }
    
    /// Create the URL to be submitted
    open func buildURL() -> URL? {
        
        let url = self.overrideURL ?? Onboarding.urlProvider?.url()
        var mutableComponents = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        
        var serviceQueryItems = [URLQueryItem]()
        self.queryItems.forEach {
            serviceQueryItems.append($0)
        }
        
        if !serviceQueryItems.isEmpty {
            mutableComponents?.queryItems = serviceQueryItems
        }
        
        mutableComponents?.path = self.serviceSpecificPath
        return mutableComponents?.url
    }
    
    /// Combines the base path, version and service suffix into a single string so that the URL may be built correctly
    open var serviceSpecificPath: String {

        let path = [self.basePath,
                    self.apiVersion.rawValue,
                    self.serviceSuffix].joined(separator: "/")
        return path
    }
    
    open func addPostBodyParameter(name: String, value: Any) {
        // to be implemented by subclasses
        assert(false, "Must be implemented by subclass")
    }
    
    open func addHeaderValue(_ value: String, forKey key: String) {
        self.additionalHeaderValues[key] = value
       
    }
}
    
extension ServiceParameters {

    public var queryItems: [URLQueryItem] {
        
        let parameterChannelToken = self.parameters.first { $0.key == ChannelTokenParameter.keyValue }
        if parameterChannelToken == nil {
            if let defaultChannelToken = Onboarding.urlProvider?.deliveryChannelToken() {
                self.parameters[ChannelTokenParameter.keyValue] = ChannelTokenParameter(defaultChannelToken)
            }
        }
        let array = self.parameters
                        .sorted { $0.0 < $1.0 }
                        .compactMap { $0.1.queryItem }
            
        return array
    }
}
