// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

/// Errors that may be encountered when implementing your own `CacheProvider`
public enum GalleryCacheError: Error {
    case cachedItemNotFound
    case unableToStoreDownloadInCache
}


/// User-provided implementation of `OracleContentCore.CacheProvider`
/// This class maintains a collection of downloaded URLs and associated Etags, indexed by the identifier of the asset downloaded
public class GalleryCacheProvider: CacheProvider {
    
    public init() {

    }
    
    /// Since we utilize Etags, we want to ensure that a fetch always takes place
    /// The actual download of the requested asset will only happen if a newer version is available
    public var cachePolicy: CachePolicy {
        .alwaysFetchWithCustomHeader
    }
   
    /// This cache utilizes Etags, so we need to ensure that the appropriate header value will be set in the request
    public func headerValues(for cacheKey: String) -> [String : String] {
       
        var etag = ""
        
        if let foundValue = GalleryFileCache.instance.items[cacheKey],
           let foundEtag = foundValue.etag {
            etag = foundEtag
        }
        
        return ["If-None-Match": etag]
    }

    /// This method is not called by OracleContentCore due to our cachePolicy
    public func find(key: String) -> URL? {
        return nil
    }
    
    /// This method is called from OracleContentCore when a 304 response was received.
    /// In this case, it is required that this class provide the previously downloaded URL associated with this key
    /// If for some reason the URL cannot be determined, throw our own error
    public func cachedItem(key: String) throws -> URL {
        if let url = GalleryFileCache.cachedItem(key: key) {
            return url
        } else {
            throw GalleryCacheError.cachedItemNotFound
        }
    }
    
    /// Called by OracleContentCore after a download has occurred. This allows us to store the URL in our cache and extract
    /// any necessary information out of the returned headers
    public func store(objectAt file: URL, key: String, headers: [AnyHashable : Any]) throws -> URL {
        
        let etagKey = headers.keys.compactMap { $0 as? String }.first { $0 == "Etag"}
        if let foundEtagKey = etagKey,
           let foundEtagValue = headers[foundEtagKey] as? String {
            
            let newURL = try GalleryFileCache.saveDownloadedFile(key: key, etag: foundEtagValue, downloadedFileURL: file)
            return newURL
        } else {
            throw GalleryCacheError.unableToStoreDownloadInCache
        }
    }
}
