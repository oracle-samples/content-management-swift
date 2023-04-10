// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/**
 Protocol used by `ImplementsDownload` so that callers can provide an Image-based cache interface when downloading assets of any type.
 This allows callers to (optionally) search for an entry in cache before executing a web service call. It also provides a mechanism for storing downloaded results back in the cache
 
 The `cachePolicy` allows for two different options.
 
 Use `CachePolicy.alwaysFetchWithCustomHeader` when your cache utilizes custom header values such as "If-None-Match" for Etag support. This will ensure that a service call to request the asset is always made. Any 304 response from the server will result in a call back to the cache to obtain the cached value.
 
 Use `CachePolicy.bypassServerCallOnFoundItem` to ensure that the service asks for a cached value before attempting the actual service call. If the cache contains an asset matching the key, then that asset is returned and no web service call is attempted
 */
public protocol ImageProvider {
    
    /// Determines whether to ask the cache for an item matching the key before attempting any web service call.
    var cachePolicy: CachePolicy { get }
    
    /// Provide your own method to return an `OracleContentCoreImage` if an entry is found in cache matching the specified key.
    /// The primary purpose of this method is to determine whether or not to make a call to the server.
    ///
    /// - note This method is only called when the cachePolicy is set to bypassServerCallOnFoundItem
    /// 
    /// - parameter key: String value representing the key in the cache
    /// - returns: OracleContentCoreImage? representing the item matching the key.  If you return a non-nil OracleContentCoreImage, then that return value will be used and the server call will be bypassed
    func find(key: String) -> OracleContentCoreImage?
    
    /// This method is used when a web service call has been made and the server returned a 304 Not Modified response. In this case, the cache has the opportunity to either provide its cached value for the key or throw an error.
    ///
    /// - parameter key: String value representing the key in the cache
    /// - returns: OracleContentCoreImage representing the image  matching the key. If none exists, throw an error so that the entire pipeline can fail. Otherwise return an OracleContentCoreImage so that the pipeline can return success
    /// - throws Error if the CacheProvider is unable to provide an OracleContentCoreImage matching the specified key
    func cachedItem(key: String) throws -> OracleContentCoreImage
    
    /// Provide your own method to store an object in cache
    /// - parameter image: The OracleContentCoreImage that should be stored in cache
    /// - parameter key: The key value of the object in the cache
    /// - parameter headers: The headers returned by the HTTPURLResponse of the web service call
    /// - throws: Error if issues exist reading or copying the image
    func store(image: OracleContentCoreImage, key: String, headers: [AnyHashable: Any]) throws
    
    /// Provide additional headers to use for the service call.
    ///
    /// A typical example might be to create a cache that supports Etag values from the server. In that case, your implementation may look like this:
    /// ```swift
    /// func headerValues(for cacheKey: String) -> [String: String] {
    ///     guard let etag = findEtagInCache(for: cacheKey) else {
    ///        return [:]
    ///     }
    ///
    ///     return ["If-None-Match": etag]
    /// }
    func headerValues(for cacheKey: String) -> [String: String]
}
