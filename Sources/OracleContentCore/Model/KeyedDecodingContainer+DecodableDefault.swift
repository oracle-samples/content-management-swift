// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

extension KeyedDecodingContainer {
    /// Extension on KeyedDecodingContainer which allows for the decoding of objects annotated with the @DefaultDecodable property wrapper
    /// This allows for the centralized decoding of objects which are marked as `Date` values.
    ///
    /// Although `Date` values are primarily represented in a container format like:
    /// ```json
    /// "createdDate": {
    /// "value": "2019-04-16T16:35:24.526Z",
    /// "timezone": "UTC"
    ///}
    ///```
    ///
    /// They may also appear as timestamp values:
    /// ```json
    /// "timestampDate": 1641812204080
    /// ```
    ///
    /// As string values with ISO8601 date strings containing fractional seconds:
    /// ```json
    /// "dateWithFractionalSeconds": "2022-01-10T10:53:39.123Z"
    /// ```
    ///
    /// or with ISO8601 date strings without fractional seconds
    /// ```json
    /// "dateWithoutFractionalSeconds": "2022-01-10T10:53:39Z"
    /// ```
    ///
    /// The decode method supplied here will attempt to handle dates in all of these formats.
    public func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                          forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        
        if T.self == DecodableDefault.Sources.DistantPastDate.self ||
           T.self == DecodableDefault.Sources.DistantFutureDate.self {
            
            // Try DateContainer representation first
            if let dc = try? decodeIfPresent(DateContainer.self, forKey: key) {
                guard let d = dc.dateValue() as? T.Value else {
                    return .init()
                }
                
                return .init(d)
            } else if let stringval = try? decodeIfPresent(String.self, forKey: key) {
                
                // Try date string with no fractional seconds
                if let d = DateRoutines.iso8601NoFractionalSecondsStringToDate(stringval) {
                    guard let returnDate = d as? T.Value else {
                        throw OracleContentError.dataConversionFailed
                    }
                    
                    return .init(returnDate)
                } else {
                    
                    // Try date string with fractional seconds
                    guard let d = DateRoutines.iso8601StringWithFractionalSecondsToDate(stringval) else {
                        return .init()
                    }
                    
                    guard let returnDate = d as? T.Value else {
                        throw OracleContentError.dataConversionFailed
                    }
                    
                    return .init(returnDate)
                }
                
            } else {
                
                // Try timestamp representation of date
                guard let int64Value = try? decodeIfPresent(Int64.self, forKey: key) else {
                    return .init()
                }
                
                let date = DateRoutines.timestampToDate(int64Value)
                
                guard let returnDate = date as? T.Value else {
                    throw OracleContentError.dataConversionFailed
                }
                return .init(returnDate)
            }
        } else {
            // Handle all other types 
            return try decodeIfPresent(type, forKey: key) ?? .init()
        }
    }
    
    public func decode(type: DecodableDefault.Wrapper<DecodableDefault.Sources.Int64Zero>.Type,
                       forKey key: Key) throws -> DecodableDefault.Int64Zero {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}
