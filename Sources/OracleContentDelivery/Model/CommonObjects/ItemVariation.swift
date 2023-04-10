// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class ItemVariation: NSObject, Codable, SupportsEmptyInitializer {
    
    @DecodableDefault.EmptyString public var status: String
    @DecodableDefault.IntZero     public var sourceVersion: Int
    @DecodableDefault.EmptyString public var varType: String
    @DecodableDefault.EmptyString public var setId: String
    @DecodableDefault.False       public var isMaster: Bool
    @DecodableDefault.False       public var isPublished: Bool
    
    @DecodableDefault.EmptyString public var slug: String
    @DecodableDefault.EmptyString public var type: String

    @DecodableDefault.DistantPastDate public var lastModified
    
    @DecodableDefault.EmptyString public var id: String
    @DecodableDefault.EmptyString public var value: String
    @DecodableDefault.EmptyList   public var link: [Link]
    @DecodableDefault.EmptyString public var name: String
    @DecodableDefault.EmptyString public var sourceId: String 
    
    public required override init() { }
}
