// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Objects conforming to this protocol will provide a URL that may be used for streaming purposes
public protocol ConvertibleToStreamingURL {
    func urlForStreaming(version: APIVersion?) -> URL?
}
