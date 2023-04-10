// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore

/**
 Read a taxonomy category
 */
public final class ReadTaxonomyCategory<Element: Decodable>: BaseService<Element>,
                                               ImplementsFetchDetail,
                                               ImplementsOverrides,
                                               ImplementsChannelToken,
                                               ImplementsVersion,
                                               ImplementsLinks,
                                               ImplementsExpand,
                                               ImplementsFields,
                                               ImplementsAdditionalHeaders {
    
    /// The configurable values allowed for the web service call
    internal typealias ServiceSpecificParameters    = ReadTaxonomyCategoryParameters
    public typealias ServiceReturnType              = ReadTaxonomyCategory<Element>
    public typealias LinksValuesConstructor         = ReadLinksValues
    public typealias FieldValuesConstructor         = TaxonomyCategoriesFieldValues

    public required init(taxonomyId: String, categoryId: String) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(taxonomyId: taxonomyId, categoryId: categoryId)
        
    }
}

internal class ReadTaxonomyCategoryParameters: SimpleDeliveryParameters {

    private var taxonomyId: String = ""
    private var categoryId: String = ""
    
    public override var serviceSuffix: String { "taxonomies/\(self.taxonomyId)/categories/\(self.categoryId)" }
    
    public convenience init(taxonomyId: String, categoryId: String) {
        self.init()

        self.taxonomyId = taxonomyId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        self.categoryId = categoryId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        
        self.parameters = [:]
    }
    
    override func isWellFormed() -> Bool {
       
        if self.taxonomyId.isEmpty {
            self.invalidURLError = OracleContentError.invalidURL("Taxonomy ID cannot be empty.")
            return false
        }
        
        if self.categoryId.isEmpty {
            self.invalidURLError = OracleContentError.invalidURL("TaxonomyCategory ID cannot be empty.")
            return false
        }
        
        return true
    }

}
