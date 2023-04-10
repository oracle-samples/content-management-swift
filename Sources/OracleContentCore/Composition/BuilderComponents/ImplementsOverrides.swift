// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Typealiases to simplify call sites
public typealias ProvidesURLRequestHeaders = () -> [String: String]
public typealias ProvidesSessionConfiguration = () -> URLSessionConfiguration?

/**
Protocol implementing composition-based overrides of URL and/or URLSessionConfiguration
Any object which conforms to this protocol will have the ability to override the URL and/or session configuration used to execute the service.
 
By providing this capability, we eliminate the need for lots of duplicate code. Uptake is exceptionally simple - conform to the protocol
 by providing  `service` and `serviceParameters`values
*/

public protocol ImplementsOverrides: BaseImplementation {
    
    /// The actual service object which performs the transport operations
    var service: BaseServiceTransport<Element>? { get set }
   
    /// Override the URL used as the web service endpoint.
    /// The URL for a service is normally determined by the values supplied by the caller as part of the SDK onboarding process.
    /// However, there are times when a one-off URL may be necessary.  This method allows a caller to provide a one-time
    /// override so that a temporary URL may be used.
    /// - parameter URL: The one-time URL to use for this particular web service call
    /// - parameter authenticationHeader: An implementation of `ProvidesAuthenticationHeader` that supplies the necessary
    /// header values to execute the service call successfully
    func overrideURL(_ url: URL, authorizationHeaders: ProvidesURLRequestHeaders?) -> Self
    
    /// Override the URLSessionConfiguration used when executing a web service
    /// The URLSessionConfiguration for a service is normally determined by the values supplied by the caller as part of the SDK onboarding process.
    /// However, there are times when a one-off configuration may be necessary.  This method allows a caller to provide a one-time
    /// override so that a temporary session may be created and used..
    /// - parameter sessionConfiguration: The one-time URLSessionConfiguration  to use for this particular web service call
    func overrideSessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> Self
    
    /// Force a single web service call to use the default URLSession
    func useDefaultSession() -> Self
    
    /// Force a single web service call to use the "no cache" URLSession
    func useNoCacheSession() -> Self

}

public protocol ImplementsDownloadOverrides: AnyObject where Self == ServiceReturnType {
    associatedtype Element: Decodable
    associatedtype ServiceReturnType
    
    var service: BaseDownloadServiceTransport? { get set }
    var serviceParameters: ServiceParameters! { get set }
    
    func overrideURL(_ url: URL, headers: ProvidesURLRequestHeaders?) -> Self
    func overrideSessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> Self
    
    func useDefaultSession() -> Self
    
    func useNoCacheSession() -> Self

}

public extension ImplementsOverrides {
    
    func overrideURL(_ url: URL, authorizationHeaders: ProvidesURLRequestHeaders? = nil) -> ServiceReturnType {
        self.serviceParameters.overrideURL = url
        self.serviceParameters.overrideURLRequestHeaders = authorizationHeaders
    
        return self
    }

    func overrideSessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> Self {
        self.serviceParameters.overrideSessionConfiguration = sessionConfiguration
        self.service?.sessionConfiguration = sessionConfiguration
        return self
    }
    
    func useDefaultSession() -> Self {
        self.serviceParameters.overrideSession = Onboarding.sessions.session()
        return self
    }
    
    func useNoCacheSession() -> Self {
        self.serviceParameters.overrideSession = Onboarding.sessions.noCacheSession()
        return self
    }
}

public extension ImplementsDownloadOverrides {
    
    func overrideURL(_ url: URL, headers: ProvidesURLRequestHeaders? = nil) -> ServiceReturnType {
        self.serviceParameters.overrideURL = url
        self.serviceParameters.overrideURLRequestHeaders = headers
        
        return self
    }

    func overrideSessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> Self {
        self.serviceParameters.overrideSessionConfiguration = sessionConfiguration
        self.service?.sessionConfiguration = sessionConfiguration
        return self
    }
    
    func useDefaultSession() -> Self {
        self.serviceParameters.overrideSession = Onboarding.sessions.session()
        return self
    }
    
    func useNoCacheSession() -> Self {
        self.serviceParameters.overrideSession = Onboarding.sessions.noCacheSession()
        return self
    }
}

public protocol ImplementsAdditionalHeaders: BaseImplementation {
    func additionalHeaders(_ headers: [String: String]) -> Self
}

public extension ImplementsAdditionalHeaders {
    
    func additionalHeaders(_ headers: [String: String]) -> Self {
        
        headers.forEach { key, value in
            self.serviceParameters.addHeaderValue(value, forKey: key)
        }
        
        return self
        
    }
}
