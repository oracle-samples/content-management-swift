// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import XCTest

extension XCTestCase {
    public func obtainComponents(_ fromURL: URL) -> URLComponents? {
        return URLComponents(url: fromURL, resolvingAgainstBaseURL: false)
    }
}
