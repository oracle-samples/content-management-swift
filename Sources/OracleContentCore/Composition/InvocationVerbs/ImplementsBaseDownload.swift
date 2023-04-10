// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

#if os(macOS)
import Cocoa
public typealias OracleContentCoreImage = NSImage
#else
import UIKit
public typealias OracleContentCoreImage = UIImage
#endif

/// There are two different types of cache policies available - each of which determines the condition under which a server call is made
/// `alwaysFetchWithCustomHeader` means that code does not initially ask the cache implementation for a possible match. Instead a server call is ALWAYS made. This is the policy intended for use when implementing (for example) an Etag based cache.
/// `bypassServerCallOnFoundItem` means that we always ask the cache implementation for an item matching the key. If the cache provider returns a value then the download process is short-circuited. The cached item is returned an no server call takes place.
public enum CachePolicy {
    case alwaysFetchWithCustomHeader            // always fetch and deal with possible 304
    case bypassServerCallOnFoundItem            // always ask for a cached item and short-circuit if returned

}

/// Download service calls return their values into this structure so that both the result and header values may be returned to the caller
/// This is most-important for callers specifying their own `CacheProvider` or `ImageProvider` implementation
/// The structure is generic over type T because some download services will persist the downloaded file to a URL while others will include file data in the body of the response.
/// Typically, T is either a `URL` or `OracleContentImage`
public struct DownloadResult<T> {
    public let result: T
    public let headers: [AnyHashable: Any]

    public init(result: T, headers: [AnyHashable: Any]) {
        self.result = result
        self.headers = headers
    }
}

/**
 Allows a conforming service to retrieve objects and store them locally through the use of various **download** invocation verbs. Callers have the ability to optionally interject handling code so that downloads may be retrieved from and saved to a cache.
 */
public protocol ImplementsBaseDownload: AnyObject where Self == ServiceReturnType {
    
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
    
    /// Perform a download operation as a Future.
    /// This invocation verb will utlize a `CacheProvider` if it exists
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - returns: Future<DownloadResult<URL>, Error>
    func download(progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error>
    
    /// Perform a download operation with completion handler
    /// This invocation verb will NOT utilize a `CacheProvider`
    /// - parameter storageLocation: URL to which the downloaded file should be written
    /// - parameter filename: Optional filename to use for the persisted file
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - parameter completion: Completion handler called when the service finishes with or without error
    func download(storageLocation: URL,
                  filename: String?,
                  progress: ((Double) -> Void)?,
                  completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void)
    
    /// Perform a download operation as a Future.
    /// This invocation verb will NOT utilize a `CacheProvider`
    /// - parameter storageLocation: URL to which the downloaded file should be written
    /// - parameter filename: Optional filename to use for the persisted file
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - returns: Future<DownloadResult<URL>, Error>
    func download(storageLocation: URL,
                  filename: String?,
                  progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error>
    
    /// Perform a download operation using Swift concurrency.
    /// This invocation verb will NOT utilize a `CacheProvider`
    /// - requires: iOS 15
    /// - parameter storageLocation: URL to which the downloaded file should be written
    /// - parameter filename: Optional filename to use for the persisted file
    /// - parameter progress: Optional function from Double to Void which is used to send fractional progress status to the caller
    /// - returns: URL
    /// - throws: Error
    @available(iOS 15.0, *)
    func downloadAsync(storageLocation: URL,
                       filename: String?,
                       progress: ((Double) -> Void)?) async throws -> DownloadResult<URL>
}

extension ImplementsBaseDownload {
    public func download(progress: ((Double) -> Void)?,
                         completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void) {
        
        self.downloadInternal(progress: progress) { result in
            switch result {
            case .success(let downloadResult):
                completion(.success(downloadResult))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func download(storageLocation: URL,
                         filename: String? = nil,
                         progress: ((Double) -> Void)?,
                         completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void) {
        
        self.storageDirectory = storageLocation
        self.storageFilename = filename
        
        self.downloadInternal(progress: progress) { result in
            switch result {
            case .success(let serverValues):

                if let storageDirectory = self.storageDirectory {
                    
                    try? FileManager.default.createDirectory(at: storageDirectory,
                                                             withIntermediateDirectories: true,
                                                             attributes: nil)
                    
                    let destination = storageDirectory.appendingPathComponent(self.storageFilename ?? serverValues.result.lastPathComponent)
                    
                    do {
                        try FileManager.default.moveItem(at: serverValues.result, to: destination)
                        completion(.success(DownloadResult(result: destination, headers: serverValues.headers)))
                    } catch {
                        completion(.failure(OracleContentError.couldNotStoreDownload))
                    }
                }
                
            case .failure:
                completion(result)
            }
        }
        
    }
}

// MARK: Combine
extension ImplementsBaseDownload {
    /// use the request from the service
    public func download(progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error> {
        return Future { promise in
            self.download(progress: progress) { result in
                promise(result)
            }
        }
    }
    
    public func download(storageLocation: URL,
                         filename: String? = nil,
                         progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error> {
        
        return Future { promise in
            self.download(storageLocation: storageLocation,
                          filename: filename,
                          progress: progress) { result in
                            
                promise(result)
            }
        }
    }
}

// MARK: Swift Concurrency
@available (iOS 15, *)
extension ImplementsBaseDownload {

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
    
    public func downloadAsync(storageLocation: URL,
                              filename: String?,
                              progress: ((Double) -> Void)?) async throws -> DownloadResult<URL> {
        
        try await withUnsafeThrowingContinuation { continuation in
            self.download(storageLocation: storageLocation, filename: filename, progress: progress) { result in
                switch result {
                case .success(let serverValues):
                    continuation.resume(returning: serverValues)
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension ImplementsBaseDownload {
    
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
