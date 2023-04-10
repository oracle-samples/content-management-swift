// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/**
 Allows a conforming service to retrieve objects and store them locally through the use of various **download** invocation verbs. Callers have the ability to optionally interject handling code so that downloads may be retrieved from and saved to a cache.
 */
public protocol ImplementsCacheProviderDownload: AnyObject where Self == ServiceReturnType {
    
    associatedtype Element: Decodable
    associatedtype ServiceReturnType
    
    /// The actual service object which performs the transport operations
    var service: BaseDownloadServiceTransport? { get set }
    
    /// The object which defines the parameters to use when performing the download
    var serviceParameters: ServiceParameters! { get set }
    
    /// Optional location to which the downloaded object should be copied
    var storageDirectory: URL? { get set }
    
    /// Optional filename to use when writing the download file to its intended storage location
    var storageFilename: String? { get set }

    /// Add a parameter to the web service. Provided so that objects conforming to this protocol can pass along necessary
    ///  parameter values to the underlying download service
    /// - parameter key: the key of the parameter to add
    /// - parameter value: the value of the parameter
    func addParameter(key: String, value: ConvertToURLQueryItem)
    
    /// Perform a download operation as a Future.
    /// This invocation verb will utlize a `CacheProvider` if it exists
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - returns: Future<DownloadResult<URL>, Error>
    func download(progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error>
    
    /// Perform a download operation with completion handler that is expecting a URL of the downloaded file.
    /// This invocation verb will utilize a `CacheProvider` if it exists
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func download(progress: ((Double) -> Void)?,
                  completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void)
    
    /// Perform a download operation using Swift concurrency. Requires iOS 15.0+
    /// This invocation verb will utlize a `CacheProvider` if it exists
    /// - requires: iOS 15.0
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - returns: DownloadResult<URL>
    /// - throws: Error
    @available(iOS 15.0, *)
    func downloadAsync(progress: ((Double) -> Void)?) async throws -> DownloadResult<URL>
    
}

extension ImplementsCacheProviderDownload {
    
    public func download(progress: ((Double) -> Void)?,
                         completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void) {
        
        // Check for cache provider
        guard let cacheKey = self.serviceParameters.cacheKey,
              let cacheProvider = self.serviceParameters.cacheProvider else {
            
            completion(.failure(OracleContentError.missingCacheProvider))
            return
        }
            
        if cacheProvider.cachePolicy == .bypassServerCallOnFoundItem {
            if let foundURL = cacheProvider.find(key: cacheKey) {
                completion(.success(DownloadResult(result: foundURL, headers: [:])))
                return
            }
        }
        
        self.downloadInternal(progress: progress) { result in
            switch result {
            case .success(let downloadResult):
                do {
                    let newURL = try cacheProvider.store(objectAt: downloadResult.result, key: cacheKey, headers: downloadResult.headers)
                    let newDownloadResult = DownloadResult<URL>(result: newURL, headers: downloadResult.headers)
                    completion(.success(newDownloadResult))
                    
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                
                switch error {
                case OracleContentError.notModified:
                    do {
                        let cachedURL = try cacheProvider.cachedItem(key: cacheKey)
                        completion(.success(DownloadResult(result: cachedURL, headers: [:])))
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                default:
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    /// use the request from the service
    public func download(progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error> {
        
        return Future { promise in
            self.download(progress: progress) { downloadResult in
                promise(downloadResult)
            }
        }
    }
    
    @available (iOS 15, *)
    public func downloadAsync(progress: ((Double) -> Void)?) async throws -> DownloadResult<URL> {
        try await withUnsafeThrowingContinuation { continuation in
            self.download(progress: progress) { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension ImplementsCacheProviderDownload {
    private func downloadInternal(progress: ((Double) -> Void)?,
                                  completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void) {
        
        guard self.serviceParameters.isWellFormed() else {
            let error = self.serviceParameters.invalidURLError ?? OracleContentError.invalidURL("")
            completion(.failure(error))
            return
        }
        
        let service = BaseDownloadServiceTransport()
        self.service = service
        let request = self.serviceParameters.request()
        
        self.service?.download(request: request,
                               progress: progress,
                               completion: completion)
    }
}
