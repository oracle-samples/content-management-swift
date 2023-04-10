// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import UIKit

/// Values tracked by our file cache
/// Since our cache is utilizing Etags, we need to track the Etag value for each file URL that we store
/// The cache itself look up these values based on the identifier of the asset that we have downloaded
public class InMemoryImageCacheValue: Codable {
    var url: URL
    var etag: String?
    
    init(url: URL, etag: String?) {
        self.url = url
        self.etag = etag
    }
}

/// This is the cache that is used to keep track of files which have been downloaded.
/// Each downloaded file will have a URL and ETag - persisted as part of an `ARDemoFileCache` object
/// Lookup of cached values is done via the asset's identifier value
public class InMemoryImageCache: ObservableObject {
    
    public static var instance = InMemoryImageCache()
    
    var items = [String: UIImage]()
    
}

public extension InMemoryImageCache {
    
    func clear() {
        
        self.items.removeAll()
    }
}
