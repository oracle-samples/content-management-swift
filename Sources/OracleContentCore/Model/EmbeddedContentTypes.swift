// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Class used to parse content types that are embedded as part of a larger "browse" operation
/// This differs from the class used when specifically requesting a listing of "content types"
public class ContentTypeId: NSObject, Codable, SupportsEmptyInitializer {
    @DecodableDefault.EmptyString public var name: String
    
    public required override init() { }
}
