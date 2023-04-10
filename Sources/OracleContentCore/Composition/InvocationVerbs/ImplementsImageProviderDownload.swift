// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
/**
 Allows a conforming service to retrieve objects and store them locally through the use of various **download** invocation verbs. Callers have the ability to optionally interject handling code so that downloads may be retrieved from and saved to a cache.
 */
public protocol ImplementsImageProviderDownload: AnyObject where Self == ServiceReturnType {
    
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
    
    /// Perform a download operation with completion handler that is expecting an OracleContentCoreImage of the downloaded file
    /// This invocation verb will utilize an `ImageProvider` if it exists
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func downloadImage(progress: ((Double) -> Void)?,
                       completion: @escaping (Result<DownloadResult<OracleContentCoreImage>, Error>) -> Void)
    
    /// Perform a download operation as a Future.
    /// This invocation verb will utlize an `ImageProvider` if it exists
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - returns: Future<DownloadResult<OracleContentCoreImage>, Error>
    func downloadImage(progress: ((Double) -> Void)?) -> Future<DownloadResult<OracleContentCoreImage>, Error>
    
    /// Perform a download operation using Swift concurrency. Requires iOS 15.0+
    /// This invocation verb will utlize a `ImageProvider` if it exists
    /// - requires: iOS 15.0
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - returns: DownloadResult<OracleContentCoreImage>
    /// - throws: Error
    @available(iOS 15.0, *)
    func downloadImageAsync(progress: ((Double) -> Void)?) async throws -> DownloadResult<OracleContentCoreImage>
    
}

extension ImplementsImageProviderDownload {
    public func downloadImage(progress: ((Double) -> Void)?,
                              completion: @escaping (Result<DownloadResult<OracleContentCoreImage>, Error>) -> Void) {
        
        // Check for image provider
        guard let cacheKey = self.serviceParameters.cacheKey,
              let imageProvider = self.serviceParameters.imageProvider else {
            
            completion(.failure(OracleContentError.missingImageProvider))
            return
        }
        
        if imageProvider.cachePolicy == .bypassServerCallOnFoundItem {
            if let foundImage = imageProvider.find(key: cacheKey) {
                completion(.success(DownloadResult(result: foundImage, headers: [:])))
                return
            }
        }
        
        self.downloadInternal(progress: progress) { result in
            switch result {
            case .success(let downloadResult):
                do {
                    if let image = OracleContentCoreImage(contentsOfFile: downloadResult.result.path) {
                        try imageProvider.store(image: image, key: cacheKey, headers: downloadResult.headers)
                        completion(.success(DownloadResult(result: image, headers: downloadResult.headers)))
                    } else {
                        completion(.failure(OracleContentError.couldNotCreateImageFromURL(downloadResult.result)))
                    }
                   
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                switch error {
                case OracleContentError.notModified:
                    do {
                        let cachedImage = try imageProvider.cachedItem(key: cacheKey)
                        completion(.success(DownloadResult(result: cachedImage, headers: [:])))
                        
                    } catch {
                        completion(.failure(error))
                    }

                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func downloadImage(progress: ((Double) -> Void)?) -> Future<DownloadResult<OracleContentCoreImage>, Error> {
        
        return Future { promise in
            self.downloadImage(progress: progress) { result in
                promise(result)
            }
        }
    }
    
    public func downloadImageAsync(progress: ((Double) -> Void)?) async throws -> DownloadResult<OracleContentCoreImage> {
        try await withUnsafeThrowingContinuation { continuation in
            self.downloadImage(progress: progress) { result in
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

extension ImplementsImageProviderDownload {

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
