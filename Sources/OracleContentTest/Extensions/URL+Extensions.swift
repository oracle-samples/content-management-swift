// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

// Create a non-optional URL when initialized by a static string
extension URL {
    public init(staticString string: StaticString) {
        self = URL(string: "\(string)")!
    }

    public var queryDictionary: [String: String]? {
        guard let query = self.query else {
            return nil
        }

        return dictionary(from: query)
    }
}

public func dictionary(from query: String) -> [String: String]? {
    var queryStrings = [String: String]()
    for pair in query.components(separatedBy: "&") {

        let key = pair.components(separatedBy: "=")[0]

        let value = pair
            .components(separatedBy: "=")[1]
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding ?? ""

        queryStrings[key] = value
    }
    return queryStrings
}
