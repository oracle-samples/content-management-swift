// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class TaxonomiesBean: NSObject, Codable, SupportsEmptyInitializer {
    /// Collection of TaxonomyItem objects
    @DecodableDefault.EmptyList public var items: [TaxonomyItem]
    
    /// Links
    @DecodableDefault.EmptyList public var links: [Link]
    
    /// Required initializer
    public required override init() { }
}

