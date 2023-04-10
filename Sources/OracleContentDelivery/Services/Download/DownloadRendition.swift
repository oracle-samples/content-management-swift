// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore 

public final class DownloadRendition: BaseDownloadService,
                                      ImplementsBaseDownload,
                                      ImplementsDownloadOverrides,
                                      ImplementsChannelToken,
                                      ImplementsVersion {
    
    public typealias Element                      = NoAsset
    internal typealias ServiceSpecificParameters  = DownloadRenditionParameters
    public typealias ServiceReturnType            = DownloadRendition
    
    public required init(
        identifier: String,
        renditionName: String,
        format: String? = nil,
        type: String? = nil
    ) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(identifier: identifier,
                                                           renditionName: renditionName,
                                                           format: format,
                                                           type: type)
    }
    
    public required init(
        identifier: String,
        renditionName: String,
        imageProvider: ImageProvider,
        cacheKey: String,
        format: String? = nil,
        type: String? = nil
    ) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(identifier: identifier,
                                                           renditionName: renditionName,
                                                           imageProvider: imageProvider,
                                                           cacheKey: cacheKey,
                                                           format: format,
                                                           type: type)
    }
    
    public required init(
        identifier: String,
        renditionName: String,
        cacheProvider: CacheProvider,
        cacheKey: String,
        format: String? = nil,
        type: String? = nil
    ) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(identifier: identifier,
                                                           renditionName: renditionName,
                                                           cacheProvider: cacheProvider,
                                                           cacheKey: cacheKey,
                                                           format: format,
                                                           type: type)
    }

}

internal class DownloadRenditionParameters: SimpleDeliveryParameters {
    private var assetIdentifier: String = ""
    private var renditionName: String = ""
       
    public override var serviceSuffix: String { "assets/\(self.assetIdentifier)/\(self.renditionName)" }

    public init(
        identifier: String,
        renditionName: String,
        format: String? = nil,
        type: String? = nil
    ) {
        super.init()
        self.assetIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        self.renditionName = renditionName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        
        if let format = format?.trimmingCharacters(in: .whitespacesAndNewlines),
           !format.isEmpty {
            let parameterValue = RenditionFormatParameter.value(format)
            self.parameters[RenditionFormatParameter.keyValue] = parameterValue
        }
        
        if let type = type?.trimmingCharacters(in: .whitespacesAndNewlines),
           !type.isEmpty {
            let parameterValue = RenditionTypeParameter.value(type)
            self.parameters[RenditionTypeParameter.keyValue] = parameterValue
        }
    }
    
    public convenience init(
        identifier: String,
        renditionName: String,
        imageProvider: ImageProvider,
        cacheKey: String,
        format: String? = nil,
        type: String? = nil
    ) {
        self.init(identifier: identifier, renditionName: renditionName, format: format, type: type)
        self.imageProvider = imageProvider
        self.cacheKey = cacheKey
    }
    
    public convenience init(
        identifier: String,
        renditionName: String,
        cacheProvider: CacheProvider,
        cacheKey: String,
        format: String? = nil,
        type: String? = nil
    ) {
        self.init(identifier: identifier, renditionName: renditionName, format: format, type: type)
        self.cacheProvider = cacheProvider
        self.cacheKey = cacheKey
    }
       
    public override func isWellFormed() -> Bool {
        if self.assetIdentifier.isEmpty {
            self.invalidURLError = OracleContentError.invalidURL("Asset identifier cannot be empty.")
            return false
        } else if self.renditionName.isEmpty {
            self.invalidURLError = OracleContentError.invalidURL("Rendition name cannot be empty.")
            return false 
        } else {
            return true
        }
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

