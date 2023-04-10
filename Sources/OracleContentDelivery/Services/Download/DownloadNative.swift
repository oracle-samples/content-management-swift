// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore

public final class DownloadNative: BaseDownloadService,
                                   ImplementsBaseDownload,
                                   ImplementsDownloadOverrides,
                                   ImplementsChannelToken,
                                   ImplementsVersion {

    public typealias Element                      = NoAsset
    internal typealias ServiceSpecificParameters  = DownloadNativeParameters
    public typealias ServiceReturnType            = DownloadNative
    
    public required init(identifier: String) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(identifier: identifier)
    }
}

internal class DownloadNativeParameters: SimpleDeliveryParameters {
    private var assetIdentifier: String = ""
       
    public override var serviceSuffix: String { "assets/\(self.assetIdentifier)/native" }

    public init(identifier: String) {
        super.init()
        self.assetIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
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
