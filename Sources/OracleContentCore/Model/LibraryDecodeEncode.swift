// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Create a JSONDecoder object with a defaultDateDecodingStrategy that can transform ``DateContainer`` responses into `Swift.Date` values.
public class LibraryJSONDecoder: JSONDecoder {
    
    public override init() {
        super.init()
        self.dateDecodingStrategy = self.defaultDateDecodingStrategy
    }
    
    /// Dates may be represented in several forms, depending on the library being used. This implementation of defaultDateDecodingStrategy allows
    /// for trying multiple types of decoding strategies and only failing if none of the known strategies succeed.
    ///
    /// Supported strategies include:
    /// * `DateContainer`
    /// ```swift
    /// {
    ///    "value": "2019-04-16T16:35:24.526Z",
    ///    "timezone": "UTC"
    /// }
    /// ```
    /// * ISO8601 With No Fractional Seconds
    /// ```swift
    /// "value": "2019-04-16T16:35:24Z",
    /// ```
    /// * Timestamp
    /// ```swift
    /// "value": 1641812204080
    /// ```
    private let defaultDateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .custom { decoder in
        
        let container = try decoder.singleValueContainer()
        
        // Try DateContainer representation first
        if let dc = try? container.decode(DateContainer.self),
    
           let date = dc.dateValue() {
            
           return date
            
        } else if let stringval = try? container.decode(String.self) {
            
            if let d = DateRoutines.iso8601NoFractionalSecondsStringToDate(stringval) {
                return d
            } else {
                
                // Try date string with fractional seconds
                if let d = DateRoutines.iso8601StringWithFractionalSecondsToDate(stringval) {
                    return d
                } else {
                    throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: container.codingPath,
                                                                                      debugDescription: "Not a valid date"))
                }
            }
            
        } else if let int64Value = try? container.decode(Int64.self) {
                let date = DateRoutines.timestampToDate(int64Value)
                return date
        } else {
            throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: container.codingPath,
                                                                              debugDescription: "Not a valid date"))
        }
       
    }
}

/// Create a JSONEncoder object with a defaultDateEncodingStrategy that can transform `Swift.Date` values into ``DateContainer`` objects
public class LibraryJSONEncoder: JSONEncoder {
    
    public override init() {
        super.init()
        self.dateEncodingStrategy = self.defaultDateEncodingStrategy
    }
    
    /// Always use `DateContainer` to encode as this is the canonical form of Date in this library
    private let defaultDateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .custom { date, encoder in
        let dateContainer = DateContainer(date: date)
        try dateContainer.encode(to: encoder)
    }
}
