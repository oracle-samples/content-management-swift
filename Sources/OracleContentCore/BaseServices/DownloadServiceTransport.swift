// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/// This is the object responsible for making download-related HTTP requests
///
open class BaseDownloadServiceTransport: SupportsCancel {
    
    /// URLSessionConfiguration used for fetching data
    internal var sessionConfiguration: URLSessionConfiguration?
    
    /// An unique identifier that can be used to track this particular web service throughout debugging, logs, collections, etc.
    internal var serviceIdentifier: String = UUID().uuidString
    
    /// Data task used to perform the actual web service call
    internal var downloadTask: URLSessionDownloadTask?
    
    /// URL to be submitted
    internal var downloadURL: URL?
  
    /// Closure allowing the transport layer to call back with updated progress statistics
    internal var progressCallback: ((Double) -> Void)?
    
    /// Store the completion closure for completion-based requests
    /// This property is unused when using Combine or Async/Await-based invocation verbs
    private var completion: ((Result<URL, Error>) -> Void)!
    
    public init() { }
    
    /// Cancel the web service
    public func cancel() {
        self.downloadTask?.cancel()
    }
    
}

extension BaseDownloadServiceTransport {
    
    /// Perform a callback-based download.
    /// - parameter request: '`URLRequest` defining the download operation
    /// - parameter progress: Optional closure of the form (Double) -> Void that will be called as download progress is updated
    /// - parameter completion: Callback closure of the form (Result<DownloadResults<URL>, Error>) -> Void
    public func download(request: URLRequest?,
                         progress: ((Double) -> Void)? = nil,
                         completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void) {
        
        guard let request = request else {
            Onboarding.logError("Could not create URLRequest for DownloadService")
            completion(Result.failure(OracleContentError.invalidRequest))
            return
        }
        
        self.progressCallback = progress 
    
        let session = self.session(from: self.sessionConfiguration)

        var observation: NSKeyValueObservation?
        
        Onboarding.logNetworkRequest(request, session: session)
        
        self.downloadTask = session.downloadTask(with: request) { fileURL, response, error in
            
            self.handleResponse(fileURL: fileURL, response: response, error: error, completion: completion)
            
            observation?.invalidate()
        }
    
        // Handle progress notifications
        observation = self.downloadTask?.progress.observe(\.fractionCompleted) { progress, _ in
            self.progressCallback?(progress.fractionCompleted)
        }
        
        // Execute the web service call
        self.downloadTask?.resume()
    }
}

extension BaseDownloadServiceTransport {

    /// Override the session configuration to use for this particular web service call
    public func addSessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) {
        self.sessionConfiguration = sessionConfiguration
    }

}

// MARK: Private methods
extension BaseDownloadServiceTransport {
    /// Return either the default session from Onboading.sessions or a new session based on the
    /// provided URLSessionConfiguration
    /// - parameter configuration: An optional URLSessionConfiguration. If supplied, a new URLSession will be created with this configuration data
    /// If no configuration is specified then the default session will be used from CaaSREST.sessions.session
    private func session(from configuration: URLSessionConfiguration?) -> URLSession {
        var returnSession: URLSession
        
        if let foundConfiguration = self.sessionConfiguration {
            returnSession = URLSession(configuration: foundConfiguration)
        } else {
            returnSession = Onboarding.sessions.session()
        }
        
        return returnSession
    }
    
    /// Transform the raw download response into a Swift Result and store the downloaded file in the temp directory
    /// - parameter fileURL: The URL to which the downloaded file was originally written
    /// - parameter response: The URLResponse received from the download attempt
    /// - parameter error: The Error received from the download attempt
    /// - parameter completion: (Result<URL, Error>) -> Void that will be called when response inspection is complete
    private func handleResponse(
        fileURL: URL?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Swift.Result<DownloadResult<URL>, Error>) -> Void
    ) {
        
        let result = ResultFromResponse.result(fileURL: fileURL,
                                               response: response,
                                               error: error)
        switch result {
        case .failure(let error):
            Onboarding.logError(error.localizedDescription)
            completion(result)
            
        case .success(let serverValues):
            let suggestedFilename = response?.suggestedFilename ?? self.serviceIdentifier + ".tmp"
            let backupFilename = "original_" + suggestedFilename
            let newFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)
            
            do {
                guard let completionURL = try FileManager.default.replaceItemAt(newFileURL,
                                                                                withItemAt: serverValues.result,
                                                                                backupItemName: backupFilename,
                                                                                options: .usingNewMetadataOnly) else {
                    
                    let error = OracleContentError.couldNotStoreDownload
                    Onboarding.logError(error.localizedDescription)
                    throw(error)
                }

                Onboarding.logNetworkResponseWithData(response as? HTTPURLResponse, data: nil)
                completion(Result.success(DownloadResult(result: completionURL, headers: serverValues.headers)))
            } catch {
                Onboarding.logError(error.localizedDescription)
                completion(.failure(error))
            }
        }
        
    }
}
