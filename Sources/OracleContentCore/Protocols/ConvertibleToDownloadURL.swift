// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Protocol that should be adopted in order to use an object as part of a DownloadService call
/// The sole purpose of this protoocol is to obtain a fully-populated URL that can be passed (ultimately) to DownloadService
public protocol ConvertibleToDownloadURL {
    func urlForDownload(version: APIVersion?, overrideURL: URL?, basePath: String?) -> URL?
}
