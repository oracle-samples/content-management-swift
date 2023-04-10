// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Enumeration defining the supported operations that make up the raw text of a search query
internal enum QueryOperation: String {
    /// Equals
    case eq
    
    /// Contains
    case co
    
    /// Starts With
    case sw
    
    /// Greater than or equal
    case ge
    
    /// Less than or equal
    case le
    
    /// Greater than
    case gt
    
    /// Less than
    case lt
    
    /// Matches
    case mt
    
    /// Similar
    case sm
    
}
