// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

// temporary extension until well-known storage is implemented
public extension FileManager {
    func clearDownloadDirectory() throws {
        
        let tmpDirURL = FileManager.default.temporaryDirectory
        let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
        try tmpDirectory.forEach { file in
            let fileUrl = tmpDirURL.appendingPathComponent(file)
            try removeItem(atPath: fileUrl.path)
        }
    }
}
