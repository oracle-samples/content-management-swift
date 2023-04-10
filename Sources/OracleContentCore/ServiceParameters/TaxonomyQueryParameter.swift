// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used by Management library when listing or reading taxonomies
public enum TaxonomyQueryParameter: String {
    case all
    case promoted
    case draft
    
}
