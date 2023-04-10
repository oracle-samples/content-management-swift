// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// A Link object returned from many of the library web services
public class Link: NSObject, Codable, SupportsEmptyInitializer {
    /// The target resource’s URI. It could be template URI.
    @DecodableDefault.EmptyString public var href: String
    
    /// Relation type.
    @DecodableDefault.EmptyString public var rel: String
    
    /// What HTTP method can be used to access the target resource.
    @DecodableDefault.EmptyString public var method: String
    
    /// Media type.
    @DecodableDefault.EmptyString public var mediaType: String
    
    /// Link to the metadata that describes the target resource.
    @DecodableDefault.EmptyString public var profile: String
    
    /// Whether the URI is a template.
    @DecodableDefault.False public var templated: Bool
    
    /// Helper property which transforms the retrieved "href" property into a URL
    public var url: URL? {
        return URL(string: self.href)
    }
    
    /// Required initializer
    public required override init() { }
}
