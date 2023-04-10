// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class Taxonomies: NSObject, Codable, ListingCommonFields, SupportsEmptyInitializer {
    
    /// Check whether there are more pages to fetch.
    @DecodableDefault.True public var hasMore: Bool
    
    /// The actual index from which the singular resources are returned.
    @DecodableDefault.UIntZero public var offset: UInt
    
    // The total number of records in the current response.
    @DecodableDefault.UIntZero public var count: UInt
    
    /// Actual page size used by the server. This might not be the same as what the client requests.
    @DecodableDefault.UIntZero public var limit: UInt
    
    /// Total number of rows that satisfy the client request
    @DecodableDefault.UIntZero public var totalResults: UInt
    
    /// Retrieved collection of Taxonomy objects
    @DecodableDefault.EmptyList public var items: [Taxonomy]
    
    /// Links
    @DecodableDefault.EmptyList public var links: [Link]
    
    public required override init() { }
}

