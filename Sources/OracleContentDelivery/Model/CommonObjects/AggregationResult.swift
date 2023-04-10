// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class AggregationResult: NSObject, Codable, SupportsEmptyInitializer {
    
    @DecodableDefault.EmptyString public var name
    
    public required override init() { }
}

