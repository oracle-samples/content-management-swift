// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

/// Syntactic sugar to allow for short-circuiting an AnyPublisher
///
/// Use this method in times when you want a one-line method of expressing the body shown here
extension AnyPublisher {
    static func shortCircuit(with error: Failure) -> AnyPublisher<Output, Failure> {
        return Future<Output, Failure> { promise in
            promise(.failure(error))
        }.eraseToAnyPublisher()
    }
}
