// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// swiftlint:disable identifier_name

import Foundation

/// Defines the supported API versions for use in this library
public enum APIVersion: Int, RawRepresentable {
    
    public typealias RawValue = String
    
    case v1
    
    /// version v1.1
    case v1_1
}

extension APIVersion {
    
    /// Obtain string representation for a given version
    public var rawValue: String {
        switch self {
            
        case .v1:
            return "v1"
            
        case .v1_1:
            return "v1.1"
        }
    }
    
    /// Build a version from the specified string
    public init?(rawValue: RawValue) {
        
        let lowercased = rawValue.lowercased()
        
        switch lowercased {
            
        case "v1":
            self = .v1
            
        case "v1.1":
            self = .v1_1
            
        default:
            return nil
        }
    }
}
