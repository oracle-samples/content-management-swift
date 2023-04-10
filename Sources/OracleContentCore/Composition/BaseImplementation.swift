// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
 This is the base protocol from which all other compositional protocols derive.
 It surfaces the `ServiceParameters` required by each compositional protocol as well as the method to add a parameter value to the service.
 
 Services conforming to any of the compositional elements must define **Element** and **ServiceReturnType**
 */
public protocol BaseImplementation: AnyObject where Self == ServiceReturnType {
    associatedtype Element: Decodable
    associatedtype ServiceReturnType
    
    /// The object which defines the parameters to use when performing the download
    var serviceParameters: ServiceParameters! { get set }
    
    /// Add a parameter to the web service. Provided so that objects conforming to this protocol can pass along necessary
    ///  parameter values to the underlying download service
    /// - parameter key: the key of the parameter to add
    /// - parameter value: the value of the parameter
    func addParameter(key: String, value: ConvertToURLQueryItem)
}
