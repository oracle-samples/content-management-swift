// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class CategoryAncestorBean: NSObject, Codable, SupportsEmptyInitializer {
    /// The id of the category
    @DecodableDefault.EmptyString public var id
    
    /// The name of the category
    @DecodableDefault.EmptyString public var name
    
    /// The apiName of the category
    @DecodableDefault.EmptyString public var apiName
    
    /// Required initializer
    public required override init() { }
}
