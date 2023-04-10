// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// JSONValue objects are generic over an "AssetType" which must be conform to both `Codable` and ``SupportsStringDescription``
/// This structure exists for cases when we need to create a JSONValue object from raw JSON which does not match any of the model objects in the library.
///
///  One example of this is converting raw JSON into JSONValue<NoAsset> when parsing error data from a web service response
public struct NoAsset: Codable, SupportsStringDescription {
    public func stringDescription() -> String {
        return "<unused>"
    }
}

