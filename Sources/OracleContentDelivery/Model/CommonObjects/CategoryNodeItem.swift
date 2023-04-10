// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class CategoryNodeItem: NSObject, Codable, SupportsEmptyInitializer {
    
    /// The id of the category node
    @DecodableDefault.EmptyString public var id: String
    
    /// The name of the category node
    @DecodableDefault.EmptyString public var name: String
    
    /// The API name of the category node
    @DecodableDefault.EmptyString public var apiName: String
    
    /// Required initializer
    public required override init() { }
}

