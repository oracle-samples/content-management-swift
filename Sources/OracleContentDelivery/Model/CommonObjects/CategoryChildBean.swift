// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class CategoryChildBean: NSObject, Codable, SupportsEmptyInitializer {
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case desc = "description"
        case apiName
        case position
        case links
    }
    
    /// The id of the category
    @DecodableDefault.EmptyString public var identifier
    
    /// The name of the category
    @DecodableDefault.EmptyString public var name
    
    @DecodableDefault.EmptyString public var desc
    
    /// The apiName of the category
    @DecodableDefault.EmptyString public var apiName
    
    /// Category node items
    @DecodableDefault.IntZero public var position
    
    /// Links
    @DecodableDefault.EmptyList public var links: [Link]
    
    /// Required initializer
    public required override init() { }
}
