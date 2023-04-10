// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore
import UIKit

/// Errors that may be encountered when implementing your own `CacheProvider`
public enum ImageCacheError: Error {
    case cachedItemNotFound
}

/// User-provided implementation of `OracleContentCore.CacheProvider`
/// This class maintains a collection of downloaded URLs and associated Etags, indexed by the identifier of the asset downloaded
public class InMemoryImageProvider: ImageProvider {
    
    public init() {
        
    }
    
    /// Since we utilize Etags, we want to ensure that a fetch always takes place
    /// The actual download of the requested asset will only happen if a newer version is available
    public var cachePolicy: CachePolicy {
        .bypassServerCallOnFoundItem
    }
   
    /// This cache utilizes Etags, so we need to ensure that the appropriate header value will be set in the request
    public func headerValues(for cacheKey: String) -> [String : String] {
        return [:]
    }

    /// Return the image found in cache
    public func find(key: String) -> UIImage? {
        return InMemoryImageCache.instance.items[key]
    }
    
    /// Not called due to the cachePolicy set
    public func cachedItem(key: String) throws -> OracleContentCore.OracleContentCoreImage {
        throw ImageCacheError.cachedItemNotFound
    }
    
    /// Called by OracleContentCore after a download has occurred. This allows us to store the URL in our cache and extract
    /// any necessary information out of the returned headers
    public func store(image: OracleContentCore.OracleContentCoreImage, key: String, headers: [AnyHashable : Any]) throws {
        
        InMemoryImageCache.instance.items[key] = image
    }
}
