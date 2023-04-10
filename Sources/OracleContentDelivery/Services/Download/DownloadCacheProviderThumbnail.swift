// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

public final class DownloadCacheProviderThumbnail: BaseDownloadService,
                                                   ImplementsCacheProviderDownload,
                                                   ImplementsDownloadOverrides,
                                                   ImplementsChannelToken,
                                                   ImplementsVersion {
    
    public typealias Element                      = NoAsset
    internal typealias ServiceSpecificParameters  = DownloadCacheProviderThumbnailParameters
    public typealias ServiceReturnType            = DownloadCacheProviderThumbnail
    
    public required init(
        identifier: String,
        cacheProvider: CacheProvider,
        cacheKey: String,
        fileGroup: String? = nil,
        advancedVideoInfo: EmbeddedAdvancedVideoInfo? = nil
    ) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(identifier: identifier,
                                                           cacheProvider: cacheProvider,
                                                           cacheKey: cacheKey,
                                                           fileGroup: fileGroup,
                                                           advancedVideoInfo: advancedVideoInfo)
    }

}

internal class DownloadCacheProviderThumbnailParameters: SimpleDeliveryParameters {
    private var downloadURL: URL?
    private var downloadable: ConvertibleToDownloadURL?
    private var assetId: String?
    private var fileGroup: String?
    private var advancedVideoInfo: EmbeddedAdvancedVideoInfo?

    public init(url: URL?) {
        self.downloadURL = url
        super.init()
    }
    
    public init(downloadable: ConvertibleToDownloadURL?) {
        self.downloadable = downloadable
        super.init()
    }
    
    public init(
        identifier: String,
        cacheProvider: CacheProvider,
        cacheKey: String,
        fileGroup: String? = nil,
        advancedVideoInfo: EmbeddedAdvancedVideoInfo? = nil
    ) {
        self.assetId = identifier
        self.advancedVideoInfo = advancedVideoInfo
        self.fileGroup = fileGroup
        super.init()
        self.cacheProvider = cacheProvider
        self.cacheKey = cacheKey
    }
    
    public override func buildURL() -> URL? {
        
        if let url = self.downloadURL {
            return url
        } else if let downloadable = self.downloadable {
            if let url = downloadable.urlForDownload(version: self.apiVersion, overrideURL: self.overrideURL, basePath: LibraryPathConstants.baseDeliveryPath) {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems?.append(contentsOf: self.queryItems)
                return components?.url
                
            } else {
                return nil
            }
        } else if let assetId = self.assetId {
            let thumbnailType = AssetThumbnailType.defaultThumbnail(for: assetId, fileGroup: self.fileGroup, advancedVideoInfo: self.advancedVideoInfo)
            if let url = thumbnailType.urlForDownload(version: self.apiVersion, overrideURL: self.overrideURL, basePath: LibraryPathConstants.baseDeliveryPath),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                
                var c = components
                c.queryItems?.append(contentsOf: self.queryItems)
                return c.url
            } else {
                return nil
            }
 
        } else {
            return nil
        }
      
    }
    
    public override func isWellFormed() -> Bool {
    
        if self.buildURL() == nil {
            self.invalidURLError = OracleContentError.invalidURL("URL could not be built for the specified download type.")
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
