// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
 Uptaking applications may  implement an object conforming to this protocol in order to define the URL used for web service calls, along with the channel token and additional header values
 
 ### Delivery Usage Example: ###
 ````
 public class MyURLProvider: URLProvider {
 
     // this makes it a singleton
     public static var instance = MyURLProvider()
     
     // initializer is private
     private init() { }
     
     // URL details are stored in my application's account store
     public var url: () -> URL? = {
        return MyAccountStore.url()
     }
     
     // Headers are not typically required for Delivery usage
     public var headers: () -> [String: String] = {
        return [:]
     }
     
     // Delivery channel token may be provided for convenience sake when every Delivery
     // call is going to access the same channel
    public var deliveryChannelToken: () -> String? = { return "123ABC456" }
 }
 
 Onboarding.urlProvider = MyURLProvider.instance
 
 ````
 */
@objc
public protocol URLProvider {
    
    /// Stores a function which returns an optional URL representing the base URL for all SDK calls
    /// The returned URL should be of the form scheme://host:port or scheme://host.
    var url: () -> URL? { get set }
    
    /**
     Function to be called to provide additional header values for web service calls. A common usage for this property is to provide authentication headers which are required to access a secure publishing channel.
     */
    var headers: () -> [String: String] { get set }
    
    /// Function to be called to obtain the deliveryChannelToken for use in `OracleContentDelivery` API service calls.
    /// This function is available so that a single channel can be specified for all calls.
    /// This value may be overridden on a call-by-call basis by explicitly setting the token builder as part of the service definition
    var deliveryChannelToken: () -> String? { get set }

}

/**
 Uptaking applications may implement an object conforming to this protocol in order to provide a logging implementation
*/
@objc
public protocol LoggingProvider {
     // User-provided error logging implementation
     func logError(_ message: String, file: String, line: UInt, function: String)
     
     // User-provided network response logging implementation
     func logNetworkResponseWithData(_ response: HTTPURLResponse?, data: Data?, file: String, line: UInt, function: String)
     
     // User-provided network requets logging implementation
     func logNetworkRequest(_ request: URLRequest?, session: URLSession?, file: String, line: UInt, function: String)
     
     // User-provided debug logging implementation
     func logDebug(_ message: String, file: String, line: UInt, function: String)
}

/**
 Uptaking applications may provide their own implementation for session and noCacheSession to provide specific configurations meeting their own needs
 */
public protocol SessionProvider {
    
    /**
     Function returning the default URLSession to use for all services except those explicitly designated to not use HTTP cache
     */
    var session: () -> URLSession { get set }
    
    /**
    Function returning the URLSession to use for all services which have been designated to avoid the use of HTTP cache
    */
    var noCacheSession: () -> URLSession { get set }
}

/**
 Default implementation of a SessionProvider protocol
 */
public struct OracleContentSessionProvider: SessionProvider {
    public var session: () -> URLSession = {
        let sessionToUse = URLSession.shared
        sessionToUse.sessionDescription = "OracleContentDefaultSession"
        sessionToUse.configuration.httpCookieStorage = HTTPCookieStorage.shared
        sessionToUse.configuration.httpCookieAcceptPolicy = .always
        sessionToUse.configuration.httpShouldSetCookies = true

        return sessionToUse
    }
       
   /// URLSession which is configured to bypass cacheing of responses
   public var noCacheSession: () -> URLSession = {
       let config = URLSessionConfiguration.default
       config.requestCachePolicy = .reloadIgnoringLocalCacheData
       config.urlCache = nil
       let session = URLSession(configuration: config)
       session.sessionDescription = "OracleContentNoCacheSession"
       
       return session
   }
    
    public init() { }
}

public typealias CaaSREST = Onboarding

/// This enumeration stores values which are necessary for library usage. Calling code must provide an implementation of `URLProvider` so that libraries have an endpoint
/// to which web services may be submitted. The other values are optional.
public enum Onboarding {
    
    /// REQUIRED `URLProvider` implementation. Calling code MUST supply this implemenation
    public static var urlProvider: URLProvider?
    
    /// An optional `LoggingProvider` implementation. Provide this implementation to capture logging data
    public static var logger: LoggingProvider?
    
    /// An optional `SessionProvider` should calling code desire more fine-grained control over the URLSessions used for service calls. The default implementation is `OracleContentSessionProvider`
    public static var sessions: SessionProvider = OracleContentSessionProvider()
    
    /// Optional collection of library-specific values. Values should be added to this property via "injection" methods in `Onboarding` extensions that may be supplied by additional libraries
    public static var librarySpecific = [String: Any]()

    /// Create a URL based on the scheme, port and host
    public static var baseURL: () -> URL? = {
        return Onboarding.urlProvider?.url()
    }
}

// MARK: Logging
extension Onboarding {
    
    @inline(__always)
    public static func logError(_ message: String,
                                file: String = #file,
                                line: UInt = #line,
                                function: String = #function) {
        
        self.logger?.logError(message, file: file, line: line, function: function)
    }
    
    @inline(__always)
    public static func logNetworkResponseWithData(_ response: HTTPURLResponse?,
                                                  data: Data?,
                                                  file: String = #file,
                                                  line: UInt = #line,
                                                  function: String = #function) {

        self.logger?.logNetworkResponseWithData(response,
                                               data: data,
                                               file: file,
                                               line: line,
                                               function: function)
    }
    
    @inline(__always)
    public static func logNetworkRequest(_ request: URLRequest?,
                                         session: URLSession?,
                                         file: String = #file,
                                         line: UInt = #line,
                                         function: String = #function) {

        self.logger?.logNetworkRequest(request,
                                     session: session,
                                     file: file,
                                     line: line,
                                     function: function)
    }
    
    @inline(__always)
    public static func logDebug(_ message: String,
                                file: String = #file,
                                line: UInt = #line,
                                function: String = #function) {
        
        self.logger?.logDebug(message, file: file, line: line, function: function)
        
    }
    
}

// MARK: Requests

extension Onboarding {
    public static func request(
        for url: URL,
        includeAuthenticationHeader: Bool = true,
        authHeaderProvider: ProvidesURLRequestHeaders? = nil
    ) -> URLRequest {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        /// Use either the provided override headers or the base headers provided by the onboarding process
        let headers = authHeaderProvider?() ?? self.urlProvider?.headers()
        headers?.forEach { key, value in
            
            // make sure not to add the Authorization header unless the request specifically needs it
             if key != "Authorization" || (key == "Authorization" && includeAuthenticationHeader) {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        urlRequest.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let alreadyContainsContentTypeHeader = urlRequest.allHTTPHeaderFields?.keys.contains { $0 == "Content-Type" } ?? false
        
        if !alreadyContainsContentTypeHeader {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest
    }
    
    public static func getRequest(
        for url: URL,
        includeAuthenticationHeader: Bool = true,
        authHeaderProvider: ProvidesURLRequestHeaders? = nil
    ) -> URLRequest {
        var urlRequest = self.request(for: url, includeAuthenticationHeader: includeAuthenticationHeader, authHeaderProvider: authHeaderProvider)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
}
