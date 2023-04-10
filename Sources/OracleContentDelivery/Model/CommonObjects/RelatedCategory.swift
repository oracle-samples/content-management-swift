// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class RelatedCategory: NSObject, Codable, SupportsEmptyInitializer {
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case desc = "description"
        case apiName
        case nodes
        case taxonomy
    }
    
    /// The id of the category
    @DecodableDefault.EmptyString public var identifier
    
    /// The name of the category
    @DecodableDefault.EmptyString public var name
    
    @DecodableDefault.EmptyString public var desc
    
    /// The apiName of the category
    @DecodableDefault.EmptyString public var apiName
    
    /// The path of the category
    @DecodableDefault.EmptyList public var nodes: [CategoryNodeItem]

    @DecodableDefault.EmptyInit public var taxonomy: RelatedTaxonomyBean
    
    /// Required initializer
    public required override init() { }
}
