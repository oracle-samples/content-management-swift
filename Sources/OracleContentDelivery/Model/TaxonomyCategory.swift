// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class TaxonomyCategory: NSObject, Codable, SupportsEmptyInitializer {
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case desc = "description"
        case apiName
        case position
        case parent
        case ancestors
        case children
        case nodes
        case links
        case relatedCategories
    }
    
    /// The id of the category
    @DecodableDefault.EmptyString public var identifier
    
    /// The name of the category
    @DecodableDefault.EmptyString public var name
    
    /// The category description
    @DecodableDefault.EmptyString public var desc
    
    /// The apiName of the category
    @DecodableDefault.EmptyString public var apiName
    
    /// The position of the Category among its siblings.
    @DecodableDefault.IntZero public var position
    
    /// The parent category
    @DecodableDefault.EmptyInit public var parent: CategoryAncestorBean
    
    /// The ancestors of the Category. First element represents the root category and the last element represents the immediate parent of the category.
    @DecodableDefault.EmptyList public var ancestors: [CategoryAncestorBean]
    
    /// Child categories listing 
    @DecodableDefault.EmptyInit public var children: CollectionPropertiesCategoryChildBean
    
    /// Category node items
    @DecodableDefault.EmptyList public var nodes: [CategoryNodeItem]
    
    /// Links
    @DecodableDefault.EmptyList public var links: [Link]
    
    ///
    @DecodableDefault.EmptyList public var relatedCategories: [RelatedCategory]
    
    ///
    @DecodableDefault.EmptyList public var synonyms: [String]
    
    /// Required initializer
    public required override init() { }
}
