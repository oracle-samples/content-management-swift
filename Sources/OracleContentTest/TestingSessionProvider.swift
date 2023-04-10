// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

internal struct TestingSessionProvider: SessionProvider {
    
    static var timeout: Double = 2.0
    
    init(timeout: Double = 2.0) {
        TestingSessionProvider.timeout = timeout 
    }
    
    static var dummySession: () -> URLSession {
        return {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [URLProtocolMock.self]
            config.timeoutIntervalForResource = timeout
            config.timeoutIntervalForRequest = timeout
            let session = URLSession(configuration: config)
            session.sessionDescription = "TestingSessionProvider.dummySession"
            return session
        }
    }
    
    static var dummyNoCacheSession: () -> URLSession {
        return { 
            let session = self.dummySession()
            session.sessionDescription = "TestingSessionProvider.dummyNoCacheSession"
            return session
        }
    }
    
    var session: () -> URLSession = TestingSessionProvider.dummySession
    
    var noCacheSession: () -> URLSession = TestingSessionProvider.dummyNoCacheSession
    
}
