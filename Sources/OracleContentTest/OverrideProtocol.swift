// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore 

/// Packages providing web service implementations should also provide a testing package that supports the methods in this protocol.
/// This allows for URLProtocol mock to determine whether a URLRequest matches an element previously enqueued
public protocol OverrideProtocol {
    
    func requestPath() -> RequestPathStruct
    func equals(template: [String], _ right: [String]) -> Bool
    func matches(requestType: RequestType, components: [String]) -> Bool

    static func key(for request: URLRequest) -> String?
}
