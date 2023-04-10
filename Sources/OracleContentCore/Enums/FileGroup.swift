// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Enumeration providing some structure to the string value returned in the "fileGroup" field of an Asset
/// Comparisons may be made throughout the system to the fileGroup value, so having *some* structure around that field
/// allows us to encapsulate the actual strings in this one location.
/// Stringly-typed values are error prone
///
/// While several cases are defined, the only case of consequence at the moment is .advancedVideos
public enum FileGroup {
    case advancedVideos
    case contentItem
    case other(String)
    
    public init?(value: String?, advancedVideo: EmbeddedAdvancedVideoInfo?) {
        
        // no point creating an object if there is no value
        guard let foundValue = value,
              !foundValue.isEmpty else {
            return nil
        }
        
        switch foundValue {
            
        case "Videos":
            if advancedVideo == nil {
                self = .other(foundValue)
            } else {
                self = .advancedVideos
            }
            
        case "contentItem":
            self = .contentItem
            
        default:
            self = .other(foundValue)
        }
    }
}

