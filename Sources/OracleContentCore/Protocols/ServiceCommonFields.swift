// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// All Listing services guarantee that the following fields will be contained
/// in the response data returned by the service call
public protocol ListingCommonFields {
    associatedtype Element
    
    /// True if more items expected from subsequent `fetchNext` calls
    var hasMore: Bool { get set }
    
    /// The index from which requests started returning data
    var offset: UInt { get set }
    
    /// The number of items returned
    var count: UInt { get set }
    
    /// The maximium number of items to return
    var limit: UInt { get }
    
    /// The total number of records
    var totalResults: UInt { get set }
    
    /// The collection of elements returns
    var items: [Element] { get set }
    
    /// Links
    var links: [Link] { get }
}

/// All Detail services guarantee that the following fields will be contained
/// in the response data returned by the service call
public protocol DetailCommonFields {
    
    /// The identifier of the item returned
    var id: String { get }
    
    /// The name of the item returned
    var name: String { get }
    
    /// The user who created the item
    var createdBy: String { get }
    
    /// The user who last modified the item
    var updatedBy: String { get }
    
    /// Links
    var links: [Link] { get }
}
