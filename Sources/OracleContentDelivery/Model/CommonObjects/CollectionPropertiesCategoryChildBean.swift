// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

open class CollectionPropertiesCategoryChildBean: NSObject, Codable, ListingCommonFields, SupportsEmptyInitializer {
    
    /// Check whether there are more pages to fetch.
    @DecodableDefault.True public var hasMore
    
    /// The actual index from which the singular resources are returned.
    @DecodableDefault.UIntZero public var offset
    
    // The total number of records in the current response.
    @DecodableDefault.UIntZero public var count
    
    /// Actual page size used by the server. This might not be the same as what the client requests.
    @DecodableDefault.UIntZero public var limit
    
    /// Total number of rows that satisfy the client request
    @DecodableDefault.UIntZero public var totalResults
    
    /// Retrieved collection of Taxonomy objects
    @DecodableDefault.EmptyList public var items: [CategoryChildBean]
    
    /// Aggregation results
    @DecodableDefault.EmptyList public var aggregationResults: [AggregationResult]
    
    /// Pinned items. Shows items pinned at the top of search list
    @DecodableDefault.EmptyList public var pinned: [String]
    
    /// Additional collection properties
    public var properties = [String: JSONValue<NoAsset>]()
    
    /// Links
    @DecodableDefault.EmptyList public var links: [Link]
    
    public required override init() { }
}
