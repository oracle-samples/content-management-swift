// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore

public final class DownloadCacheProviderNative: BaseDownloadService,
                                                ImplementsCacheProviderDownload,
                                                ImplementsDownloadOverrides,
                                                ImplementsChannelToken,
                                                ImplementsVersion {

    public typealias Element                      = NoAsset
    internal typealias ServiceSpecificParameters  = DownloadCacheProviderNativeParameters
    public typealias ServiceReturnType            = DownloadCacheProviderNative
    
    public required init(identifier: String,
                         cacheProvider: CacheProvider,
                         cacheKey: String) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(identifier: identifier, cacheProvider: cacheProvider, cacheKey: cacheKey)
    }
}

internal class DownloadCacheProviderNativeParameters: SimpleDeliveryParameters {
    private var assetIdentifier: String = ""
       
    public override var serviceSuffix: String { "assets/\(self.assetIdentifier)/native" }
    
    public init(identifier: String, cacheProvider: CacheProvider, cacheKey: String) {
        super.init()
        self.assetIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        self.cacheProvider = cacheProvider
        self.cacheKey = cacheKey
    }
       
    public override func isWellFormed() -> Bool {
        if self.assetIdentifier.isEmpty {
            self.invalidURLError = OracleContentError.invalidURL("Asset identifier cannot be empty.")
            return false
        }
        
        return true
    }
    
    public override func request() -> URLRequest? {
        var request = super.request()
        if let cacheKey = self.cacheKey {
            if let imageProvider = self.imageProvider {
                imageProvider.headerValues(for: cacheKey).forEach { key, value in
                    request?.addValue(value, forHTTPHeaderField: key)
                }
            } else if let cacheProvider = self.cacheProvider {
                cacheProvider.headerValues(for: cacheKey).forEach { key, value in
                    request?.addValue(value, forHTTPHeaderField: key)
                }
            }
        }
        
        return request
    }
}

