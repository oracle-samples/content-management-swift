// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine

public protocol SupportsCancel {
    func cancel()
}

/// Any object which can execute a web service call must support methods
/// to both cancel an outstanding request and obtain the URL to be used
public protocol LibraryFetchable: SupportsCancel {

    var serviceIdentifier: String { get }

    var url: URL? { get }

    var request: URLRequest? { get }
    
    func cancel()
}

public protocol FetchDownload {

    var url: URL? { get }
    var request: URLRequest? { get }
    
    func cancel()
    func download(completion: @escaping (Swift.Result<URL, Error>) -> Void)
}
