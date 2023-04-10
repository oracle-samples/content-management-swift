// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public enum TestingError: Error {
    
    // A method parameter is unexpectedly nil
    case nilParameter(_ name: String)
    
    // A model property is unexpectedly nil
    case nilProperty(_ name: String)
    
    // Item requested was not found
    case noMoreItems
    
    // An asset was not in the right status for an operation
    case unexpectedStatus
    
    // The particular type of item being accessed is of the wrong type
    case itemNotSupported
    
    // Server does not support the API we need
    case serverTooOld
    
    // some AV streaming error
    case itemNotPlayable
    
    case internalError(_ unlocalizedMessage: String)
    
}
