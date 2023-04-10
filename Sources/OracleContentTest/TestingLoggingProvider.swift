// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

public class TestingLoggingProvider: LoggingProvider {
    // The following variables exist only for testing purposes
     public var errorString = [ConfigurationErrorData]()
     public var debugString = [ConfigurationDebugData]()
     public var networkResponseString = [ConfigurationNetworkResponseData]()
     public var networkRequestString = [ConfigurationNetworkRequestData]()
    
    public func logError(_ message: String,
                         file: String = #file,
                         line: UInt = #line,
                         function: String = #function) {
        
        self.errorString.append(ConfigurationErrorData(message,
                                                       file: file,
                                                       line: line,
                                                       function: function))
    }
    
    public func logNetworkResponseWithData(_ response: HTTPURLResponse?,
                                           data: Data?,
                                           file: String = #file,
                                           line: UInt = #line,
                                           function: String = #function) {
        
        self.networkResponseString
            .append(ConfigurationNetworkResponseData(response: String(describing: response),
                                                     data: String(describing: data),
                                                     file: file,
                                                     line: line,
                                                     function: function))
    }
    
    public func logNetworkRequest(_ request: URLRequest?, session: URLSession?, file: String = #file, line: UInt = #line, function: String = #function) {
        
        self.networkRequestString
            .append(ConfigurationNetworkRequestData(response: String(describing: request),
                                                    session: String(describing: session),
                                                    file: file,
                                                    line: line,
                                                    function: function))
    }
    
    public func logDebug(_ message: String, file: String = #file, line: UInt = #line, function: String = #function) {
        
        self.debugString.append(ConfigurationDebugData(message,
                                                       file: file,
                                                       line: line,
                                                       function: function))
    }
    
}
