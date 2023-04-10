// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class Assets: NSObject, Codable, ListingCommonFields, SupportsEmptyInitializer {
    @DecodableDefault.True public var hasMore: Bool
    @DecodableDefault.UIntZero public var offset: UInt
    @DecodableDefault.UIntZero public var count: UInt
    @DecodableDefault.UIntZero public var limit: UInt
    @DecodableDefault.UIntZero public var totalResults: UInt
    @DecodableDefault.EmptyList public var items: [Asset]
    @DecodableDefault.EmptyList public var links: [Link]
    
   public required override init() { }
}
