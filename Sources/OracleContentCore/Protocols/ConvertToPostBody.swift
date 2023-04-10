// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Web services which require POST operations should define their parameters object so that it conforms to this protocol
/// This allows the "common" implementation to obtain the correct data which should populate the URLRequest's httpBody.
public protocol ConvertToPostBody {
    
    /// Perform necessary logic to format parameters so that they can be inserted as an HTTP post body
    /// - returns: String?
    func postBody() throws -> String?
}
