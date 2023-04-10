// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

//public class TestingCommonURL: URLProvider {
//    public var url: () -> URL? = {
//        return URL(staticString: "http://localhost:2123")
//    }
//    
//    public var deliveryChannelToken: () -> String? = {
//        return nil 
//    }
//    
//    public var headers: () -> [String: String] = {
//        
//        let username = "admin1"
//        let password = "password123"
//        let encodeString = "\(username):\(password)"
//        let encodeData = encodeString.data(using: .utf8)
//        if let credentials = encodeData?.base64EncodedString() {
//            return ["Authorization": "Basic:" + credentials]
//        } else {
//            return [:]
//        }
//    }
//}

/// Testing only structure to store data supplied by logDebug
public class ConfigurationDebugData: NSObject {
    var message: String
    var file: String
    var line: UInt
    var function: String

    init(_ message: String, file: String, line: UInt, function: String) {
        self.message = message
        self.file = file
        self.line = line
        self.function = function
    }
}

/// Testing only structure to store data supplied by logError
public class ConfigurationErrorData: NSObject {
    var message: String
    var file: String
    var line: UInt
    var function: String

    init(_ message: String, file: String, line: UInt, function: String) {
        self.message = message
        self.file = file
        self.line = line
        self.function = function 
    }
}

/// Testing only structure to store data supplied by logNetworkRequest
public class ConfigurationNetworkRequestData: NSObject {
    var request: String
    var session: String
    var file: String
    var line: UInt
    var function: String

    init(response: String, session: String, file: String, line: UInt, function: String) {
        self.request = response
        self.session = session
        self.file = file
        self.line = line
        self.function = function
    }
}

/// Testing only structure to store data supplied by logNetworkResponseWithData
public class ConfigurationNetworkResponseData: NSObject {
    var response: String
    var data: String
    var file: String
    var line: UInt
    var function: String

    init(response: String, data: String, file: String, line: UInt, function: String) {
        self.response = response
        self.data = data
        self.file = file
        self.line = line
        self.function = function
    }
}
