// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class RelatedTaxonomyBean: NSObject, Codable, SupportsEmptyInitializer {
    /// The id of the taxonomy
    @DecodableDefault.EmptyString public var id
    
    /// The name of the taxonomy
    @DecodableDefault.EmptyString public var name
    
    /// The short name of the taxonomy
    @DecodableDefault.EmptyString public var shortName
    
    /// Required initializer
    public required override init() { }
}
