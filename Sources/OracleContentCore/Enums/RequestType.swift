// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Enumeration for GET, POST, DELETE and PUT web service methods
public enum RequestType: Int, RawRepresentable {
    
    public typealias RawValue = String
    
    case post
    case get
    case delete
    case put
    
    public var rawValue: String {
        switch self {
        case .post:
            return "POST"
            
        case .get:
            return "GET"
            
        case .delete:
            return "DELETE"
            
        case .put:
            return "PUT"
        }
    }
    
    public init?(rawValue: RawValue) {
        
        let lowercased = rawValue.lowercased()
        
        switch lowercased {
        case "post":
            self = .post
            
        case "get":
            self = .get
            
        case "delete":
            self = .delete
            
        case "put":
            self = .put
            
        default:
            return nil
        }
    }
}
 
