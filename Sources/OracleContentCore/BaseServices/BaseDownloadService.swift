// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
This is the web service from which all download services derive. It provides a common structure and interface for all connections to the
underlying Oracle Content REST API.
 
*/
open class BaseDownloadService: LibraryFetchable {
    
    /// The entity that actually performs network operations
    public var service: BaseDownloadServiceTransport?
    
    /// The parameters that make up the request
    public var serviceParameters: ServiceParameters!
    
    /// An unique identifier that can be used to track this particular web service throughout debugging, logs, collections, etc.
    public var serviceIdentifier: String {
        service?.serviceIdentifier ?? ""
    }
    
    /// The URLRequest to be submitted
    public var request: URLRequest? {
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
    /// Parameters will ultimately take the form of `<key>=<value>`
    /// - parameter key: `String` value representing the key portion of the parameter
    /// - parameter value: `ConvertToURLQueryItem` object that will format the value portion of the parameter
    public func addParameter(key: String, value: ConvertToURLQueryItem) {
        self.serviceParameters.parameters[key] = value
    }
    
    /// Cancel the web service
    public func cancel() {
        self.service?.cancel()
    }
    
    /// Optional directory location where downloaded files should be written
    public var storageDirectory: URL?
    
    /// Optional filename to use when writing a file
    public var storageFilename: String?
    
    public init() { }
}
