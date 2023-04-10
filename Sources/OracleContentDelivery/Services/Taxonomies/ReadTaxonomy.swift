// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore 

/**
Reads a single taxonomy
 */
public final class ReadTaxonomy<Element: Decodable>: BaseService<Element>,
                                               ImplementsFetchDetail,
                                               ImplementsOverrides,
                                               ImplementsChannelToken,
                                               ImplementsVersion,
                                               ImplementsLinks,
                                               ImplementsExpand,
                                               ImplementsAdditionalHeaders {
    
    /// The configurable values allowed for the web service call
    internal typealias ServiceSpecificParameters    = ReadTaxonomyParameters
    public typealias ServiceReturnType              = ReadTaxonomy<Element>
    public typealias LinksValuesConstructor         = ReadLinksValues

    public required init(taxonomyId: String) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(taxonomyId: taxonomyId)
        
    }
}

internal class ReadTaxonomyParameters: SimpleDeliveryParameters {

    private var taxonomyId: String = ""
    
    public override var serviceSuffix: String { "taxonomies/\(self.taxonomyId)" }
    
    public convenience init(taxonomyId: String) {
        self.init()

        self.taxonomyId = taxonomyId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        self.parameters = [:]
    }
    
    override func isWellFormed() -> Bool {
       
        if self.taxonomyId.isEmpty {
            self.invalidURLError = OracleContentError.invalidURL("Taxonomy ID cannot be empty.")
            return false
        }
        
        return true
    }

}
