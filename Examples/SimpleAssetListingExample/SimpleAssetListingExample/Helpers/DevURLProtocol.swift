// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

/// Development class which allows for man-in-the-middle injection of a URLProtocol
/// The net result is that we will be able to use CharlesProxy for OCE SDK https connections
/// This class is utilized when you enable the "Use Dev Proxy" tweak in Settings
public class DevURLProtocol: URLProtocol, URLSessionDelegate, URLSessionDataDelegate {
    
    var session: URLSession?
    var myRequest: URLRequest?
    
    public static func updateCaasSessions() {
        
        

            CaaSREST.sessions.session = {
         
                let config = URLSessionConfiguration.ephemeral
                config.requestCachePolicy = .reloadIgnoringLocalCacheData
                config.protocolClasses = [DevURLProtocol.self]
                let session = URLSession(configuration: config)
                session.sessionDescription = "TestingSessionProvider.dummySession"
                return session
            }
            
            CaaSREST.sessions.noCacheSession = {
                let config = URLSessionConfiguration.ephemeral
                config.requestCachePolicy = .reloadIgnoringLocalCacheData
                config.protocolClasses = [DevURLProtocol.self]
                let session = URLSession(configuration: config)
                session.sessionDescription = "TestingSessionProvider.dummySession"
                return session
            }
            
        
    }
    
    public override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    /// Overridden implementation to indicate that we are really just ignoring this method by sending back what we were given
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        let config = CaaSREST.sessions.session().configuration
        config.protocolClasses = []
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.myRequest = request
        
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    public override func startLoading() {
        guard let request = self.myRequest else { return }
        session?.dataTask(with: request).resume()
    }
    
    public override func stopLoading() { }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        
        let authMethod = challenge.protectionSpace.authenticationMethod
        print(authMethod)
        
        var handled = false
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                handled = true
            }
        }
        
        if !handled {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        var handled = false
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                handled = true
            }
        }
        
        if !handled {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }
}


