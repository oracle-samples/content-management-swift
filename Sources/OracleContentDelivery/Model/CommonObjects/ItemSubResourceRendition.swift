// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class ItemSubResourceRendition: NSObject, Codable, SupportsEmptyInitializer {
    
    @DecodableDefault.EmptyList public var items: [RenditionBean]
    @DecodableDefault.EmptyList public var links: [Link]
    
    public required override init() { }
}

open class RenditionBean: NSObject, Codable, SupportsEmptyInitializer {
    
    @DecodableDefault.EmptyList public var formats: [RenditionFormatBean]
    @DecodableDefault.EmptyString public var type: String
    
    public required override init() { }
}

open class RenditionFormatBean: NSObject, Codable, SupportsEmptyInitializer {
    
    @DecodableDefault.EmptyString public var format: String
    @DecodableDefault.EmptyList public var links: [Link]
    
    public required override init() { }
}
