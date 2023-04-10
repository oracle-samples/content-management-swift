// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public enum DateRoutines {
    public static func timestampToDate(_ val: Int64) -> Date {
        let d = Double(val)
        let date = Date(timeIntervalSince1970: d/1000)
        return date
    }
    
    public static func dateToTimestamp(_ d: Date) -> Int64 {
        let t = d.timeIntervalSince1970
        let i: Int64 = Int64(t * 1000)
        return i
    }
    
    public static func dateToISO8601WithFractionalSeconds(_ d: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: d)
    }
    
    public static func dateToISO8601NoFractionalSeconds(_ d: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f.string(from: d)
    }
    
    public static func iso8601NoFractionalSecondsStringToDate(_ val: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: val)
    }
    
    public static func iso8601StringWithFractionalSecondsToDate(_ val: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: val)
    }
}
