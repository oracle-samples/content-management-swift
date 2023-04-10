// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
 This is the web service from which all non-download services derive. It provides a common structure and interface for all connections to the
 underlying Oracle Content REST API.
 
 The BaseService class is generic over `Element` which must be a `Decodable` object. This represents the structure into which results will be parsed
 
 */
open class BaseService<Element: Decodable>: LibraryFetchable {

    /// The entity that actually performs network operations
    public var service: BaseServiceTransport<Element>?
    
    /// The parameters that make up the request
    public var serviceParameters: ServiceParameters!
    
    /// An unique identifier that can be used to track this particular web service throughout debugging, logs, collections, etc.
    public var serviceIdentifier: String {
        service?.serviceIdentifier ?? ""
    }
    
    /// The URLRequest to be submitted
    open var request: URLRequest? {
        self.serviceParameters.request()
    }
    
    /// The URL to be submitted
    public var url: URL? {
        self.serviceParameters.buildURL()
    }
    
    /// Provides the ability to specify the particular version of the SDK API to be used. In practice, this will only be used for temporary development
    /// purposes while performing rolling upgrades of servers.
    /// - parameter version: `APIVersion` for the server against which web services execute
    public func addVersion(_ version: APIVersion) {
        self.serviceParameters.apiVersion = version
    }
    
    /// Add a parameter value for the specified key to the web service.
    ///
    /// Parameters will ultimately take the form of `<key>=<value>`
    /// - parameter key: `String` value representing the key portion of the parameter
    /// - parameter value: `ConvertToURLQuery/Item` object that will format the value portion of the parameter
    public func addParameter(key: String, value: ConvertToURLQueryItem) {
        self.serviceParameters.parameters[key] = value
    }
    
    /// Cancel the web service
    public func cancel() {
        self.service?.cancel()
    }
    
    /// Property indicating whether a web service call is expected to return additional data if called again
    ///
    /// This property is only useful for web services that perform "listing" requests as those services are typically called
    /// by specifying "offset" and "limit" values.
    ///
    /// If a listing service is called with offset = 0 and limit = 5, but the web service returns that 100 records exist in total,
    /// then the `hasMore` property will be true.
    ///
    /// On the other hand, if a listing service is called with offset = 0 and limit = 100, but only 5 records exist in total,
    /// the the `hasMore` property will be false.
    ///
    /// Finally, the `hasMore` property will be false after calling a web service designed to retrieve "detail" information for
    /// a single object.
    public var hasMore: Bool {
        get {
            self.serviceParameters.hasMore
        }
        set {
            self.serviceParameters.hasMore = newValue
        }
    }
    
    public init() { }
}
