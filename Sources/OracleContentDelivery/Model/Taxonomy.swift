// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class Taxonomy: NSObject, Codable, SupportsEmptyInitializer {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case desc = "description"
        case shortName
        case customProperties
        case updatedDate
        case createdDate
        case links
    }
    
    @DecodableDefault.EmptyString public var identifier
    @DecodableDefault.EmptyString public var name
    @DecodableDefault.EmptyString public var desc
    @DecodableDefault.EmptyString public var shortName
    public var customProperties: [String: String]?
    @DecodableDefault.EmptyList public var links: [Link]
    
    public required override init() { }
    
    public var createdDate: Date?
    public var updatedDate: Date? 
    
}
