// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

public enum BundleError: Error {
    case missingFile
}

extension Decodable {
    /// Testing only extension allowing for deserialization of a static response
    /// - parameter fileName: The name of the file. "json" is assumed to be the file extension if not supplied
    public static func decodeFromFile(named fileName: String,
                                      in bundle: Bundle = .main) throws -> Self {
        
        var fileExtension = (fileName as NSString).pathExtension
        if fileExtension.isEmpty {
            fileExtension = "json"
        }
        
        let newFileName = (fileName as NSString).deletingPathExtension
        
        guard let path = bundle.path(forResource: newFileName,
                                     ofType: "json") else {
                                        throw BundleError.missingFile
        }
        
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = LibraryJSONDecoder()
        do {
            return try decoder.decode(self, from: data)
        } catch let error {
            Onboarding.logError("Unable to parse input file. Error = \(error)")
            throw error
        }
       
    }
}
