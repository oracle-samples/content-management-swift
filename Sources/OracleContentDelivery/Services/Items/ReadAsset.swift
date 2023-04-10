// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore 

/// Returns a published digital asset or content item from a specific publishing channel. 
public final class ReadAsset<Element: Decodable>: BaseService<Element>,
                                            ImplementsFetchDetail,
                                            ImplementsOverrides,
                                            ImplementsChannelToken,
                                            ImplementsVersion,
                                            ImplementsLinks,
                                            ImplementsExpand,
                                            ImplementsAdditionalHeaders {
    
    public typealias ServiceReturnType      = ReadAsset<Element>
    public typealias LinksValuesConstructor = ReadLinksValues
    
    public required init(assetId: String) {
        super.init()
        self.serviceParameters = ReadAssetParameters(assetId: assetId)
    }
    
    public required init(slug: String) {
        super.init()
        self.serviceParameters = ReadAssetParameters(slug: slug)
    }
}

internal class ReadAssetParameters: SimpleDeliveryParameters {
    
    private enum FunctionType {
        case bySlug(String)
        case byAssetId(String)
    }
    
    private var functionType: FunctionType = .byAssetId("")
    
    public override var serviceSuffix: String {
        
        switch self.functionType {
        case .bySlug(let slug):
             return "items/.by.slug/\(slug)"
        case .byAssetId(let identifier):
            return "items/\(identifier)"
        }
    }
    
    internal init(assetId: String) {
        
        super.init()
        
        let assetId = assetId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        self.functionType = FunctionType.byAssetId(assetId)
        self.parameters = [
            ExpandValues.keyValue: ExpandValues(.all)
        ]
        
        // make sure and include the authentication header (if available)
        // so that we can access assets in a secure publishing channel
        self.includeAuthenticationHeader = true
    }
    
    internal init(slug: String) {
        
        super.init()
        
        let slug = slug.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        self.functionType = FunctionType.bySlug(slug)
        self.parameters = [
            ExpandValues.keyValue: ExpandValues(.all)
        ]
        
        // make sure and include the authentication header (if available)
        // so that we can access assets in a secure publishing channel
        self.includeAuthenticationHeader = true
    }
    
    public override func isWellFormed() -> Bool {
        switch self.functionType {
        case .bySlug(let slug):
            if slug.isEmpty {
                self.invalidURLError = OracleContentError.invalidURL("Slug cannot be empty.")
                return false
            }
            return true
            
        case .byAssetId(let assetId):
            if assetId.isEmpty {
                self.invalidURLError = OracleContentError.invalidURL("Asset ID cannot be empty.")
                return false
            }
             
            return true 
        }
    }
}
