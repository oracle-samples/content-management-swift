// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

public class TestingURLProvider: URLProvider {
    public var url: () -> URL? = {
        return URL(staticString: "http://localhost:2112")
    }
    
    public var deliveryChannelToken: () -> String? = {
        return nil
    }
    
    public var headers: () -> [String: String] = {
        
        let username = "admin1"
        let password = "password123"
        let encodeString = "\(username):\(password)"
        let encodeData = encodeString.data(using: .utf8)
        if let credentials = encodeData?.base64EncodedString() {
            return ["Authorization": "Basic:" + credentials]
        } else {
            return [:]
        }
    }
    
    public init() { }
}
