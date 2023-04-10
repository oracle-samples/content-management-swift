// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

extension EmbeddedRenditionFormat: ConvertibleToDownloadURL {
    /// Ensure that a rendition can be downloaded by making the EmbeddedRenditionFormat conform to the ConvertibleToDownloadURL protocol
    /// In this way, services that ultimately call a form of DownloadService may be invoked when a rendition is passed into them
    public func urlForDownload(version: APIVersion? = nil, overrideURL: URL? = nil, basePath: String? = nil) -> URL? {
        return self.links.first?.url
    }
}
