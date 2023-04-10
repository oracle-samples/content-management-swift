// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore 

open class TaxonomyItem: NSObject, Codable, SupportsEmptyInitializer {
    
    /// The id of the taxonomy.
    @DecodableDefault.EmptyString public var id: String
    
    /// The name of the taxonomy
    @DecodableDefault.EmptyString public var name: String
    
    /// The short name of the taxonomy
    @DecodableDefault.EmptyString public var shortName: String
    
    /// Taxonomy categories
    @DecodableDefault.EmptyInit public var categories: TaxonomyCategories
    
    /// Links
    @DecodableDefault.EmptyList public var links: [Link]
    
    /// Required initializer
    public required override init() { }
    
}

