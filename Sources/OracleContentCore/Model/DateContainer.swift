// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Class used to parse date values from library SDK responses
///
/// "Dates" are received in JSON structures that may look like this:
/// ```swift
/// {
///    "value": "2019-04-16T16:35:24.526Z",
///    "timezone": "UTC"
/// }
/// ```
/// Those values need to be parsed and then transformed into true `Date` objects. This class handles the encoding and decoding.
///
public class DateContainer: NSObject, Codable, SupportsEmptyInitializer {
    
    enum CodingKeys: String, CodingKey {
        case value
        case timezone
    }
    
    /// Date string of the format "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    @DecodableDefault.EmptyString public var value: String
    
    // ignore this because dates are in UTC time
    @DecodableDefault.EmptyString public var timezone: String
    
    /// Helper method to transform the retrieved "value" string into a true Date, using iso8601Full DateFormatter
    public func dateValue() -> Date? {
        return DateRoutines.iso8601StringWithFractionalSecondsToDate(self.value)
    }
    
    /// Helper to extract the value property, which is represented as String
    public func stringValue() -> String? {
        return self.value
    }
    
    /// Required initializer
    public required override init() { }
    
    /// Convenience initializer which can transform a Date value into "value" and "timezone" properties
    public convenience init(date: Date?) {
        self.init()
        
        guard let foundDate = date else {
            return
        }
        
        let dateComponents = Calendar.current.dateComponents([.timeZone], from: foundDate)
        
        guard let timezoneName = dateComponents.timeZone?.identifier else {
            return
        }
        
        self.value = DateRoutines.dateToISO8601WithFractionalSeconds(foundDate)

        self.timezone = timezoneName
    }
}
