// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Extension on String allowing for base64 encoding/decoding of values. Used when creating header values for web services requiring BasicAuth authentication.
extension String {
    
    func base64Decode() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func base64Encode() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
