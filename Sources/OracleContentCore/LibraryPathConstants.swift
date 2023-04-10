// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Constant values used throughout the various Oracle Content SDK implementations
public class LibraryPathConstants: NSObject {

    /// This is the current version of the web service APIs
    public static let currentAPIVersion   = APIVersion.v1_1
    
    /// The top-level path for management API requests
    public static var baseManagementPath  = "/content/management/api"
    
    /// The top-level path delivery API requests
    public static var baseDeliveryPath    = "/content/published/api"
    
    /// The top-level path for system API requests
    public static var baseSystemPath      = "/system/api"
    
    public static var baseDocumentsPath   = "/documents/mobile/ios"

}
    
