// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

// This a helper file that allows for support of both iOS and macOS versions of the Oracle libraries.

#if os(macOS)
import Cocoa

/// Support macOS versions of the libraries  by typealiasing UImage to NSImage
public typealias UIImage = NSImage

public extension NSImage {
    /// Helper method for macOS since there is no native cgImage method available on that platform
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
        
        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }
}

#else
import UIKit

#endif
