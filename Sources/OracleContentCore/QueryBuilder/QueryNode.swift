// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// User-facing node class which defines the supported query operations
///
/// Supported date/datetime formats (24Hrs)
/// ```
/// Format                                  Example
/// YYYY-MM-DD                              1989-03-26
/// YYYY/MM/DD                              1989/03/26
/// DD-MM-YYYY                              26-03-1989
/// DD/MM/YYYY                              26/03/1989
/// YYYY-MM-DD''T''hh:mm:ss                 1989-03-26T18:32:38
/// YYYY/MM/DD''T''hh:mm:ss                 1989/03/26T18:32:38
/// DD-MM-YYYY''T''hh:mm:ss                 26-03-1989T18:32:38
/// DD/MM/YYYY''T''hh:mm:ss                 26/03/1989T18:32:38
/// YYYY-MM-DD''T''hh:mm:ss.SSS             1989-03-26T18:32:38.840
/// YYYY/MM/DD''T''hh:mm:ss.SSS             1989/03/26T18:32:38.840
/// DD-MM-YYYY''T''hh:mm:ss.SSS             26-03-1989T18:32:38.840
/// DD/MM/YYYY''T''hh:mm:ss.SSS             26/03/1989T18:32:38.840
/// YYYYMMDD                                19890326
/// YYYYMMDDhhmmss                          19890326183238
/// YYYYMMDDhhmmssSSS                       19880326183238840
/// YYYY-MM-DD''T''hh:mm:ss.SSS+/-HH:mm     1989-03-26T18:32:38.840+05:30
/// YYYY-MM-DD''T''hh:mm:ss+/-HH:mm         1989-03-26T18:32:38+05:30
/// ```

public class QueryNode: NSObject, QueryToString, Comparable {
   
    /// Enumeration to support the various value formats supported by query operations
    private enum QueryNodeValue {
        case string(String)
        case date(Date, DateFormatter)
        case int(Int)
        case double(Double)
        case rawText(String)
    }
    
    /// Determines the relationship between field and nodeValue
    internal let operation: QueryOperation?
    
    /// The field name to be tested
    private let field: String?
    
    /// The value for the test
    private let nodeValue: QueryNodeValue
    
    /// Create a QueryNode which is testing a String value
    private init(field: String, operation: QueryOperation, stringValue: String) {
        self.operation = operation
        self.field = field
        self.nodeValue = .string(stringValue)
    }
    
    /// Create a QueryNode which is testing a Date value
    private init(field: String, operation: QueryOperation, dateValue: Date, formatter: DateFormatter) {
        self.operation = operation
        self.field = field
        self.nodeValue = .date(dateValue, formatter)
    }
    
    /// Create a QueryNode which is testing an Int value
    private init(field: String, operation: QueryOperation, intValue: Int) {
        self.operation = operation
        self.field = field
        self.nodeValue = .int(intValue)
    }
    
    /// Create a QueryNode which is testing a Double value
    private init(field: String, operation: QueryOperation, doubleValue: Double) {
        self.operation = operation
        self.field = field
        self.nodeValue = .double(doubleValue)
    }
    
    /// Create a QueryNode which uses a user-provided raw text string
    private init(rawText: String) {
        self.operation = nil
        self.field = nil
        self.nodeValue = .rawText(rawText)
    }
    
    /// Order two QueryNodes based on the field for which they provide values 
    public static func < (lhs: QueryNode, rhs: QueryNode) -> Bool {
        return lhs.field ?? "" < rhs.field ?? ""
    }
    
    /// Equals operator (eq) matches the exact value supplied in the query.
    ///
    /// This operator is not applicable to multivalued data types.
    /// The value provided with this operator is not case-sensitive except for standard fields.
    /// This operator considers even special characters in the value.
    ///
    /// Supported data types: text, reference, number, decimal, boolean, datetime.
    public class func equal(field: String, value: String) -> QueryNode {
        return QueryNode(field: field, operation: .eq, stringValue: value)
    }
    
    /// Equals operator (eq) matches the exact value supplied in the query.
    public class func equal(field: String, intValue: Int) -> QueryNode {
        return QueryNode(field: field, operation: .eq, intValue: intValue)
    }
    
    /// Equals operator (eq) matches the exact value supplied in the query.
    public class func equal(field: String, doubleValue: Double) -> QueryNode {
        return QueryNode(field: field, operation: .eq, doubleValue: doubleValue)
    }
    
    /// Equals operator (eq) matches the exact value supplied in the query.
    public class func equal(field: String, dateValue: Date, formatter: DateFormatter) -> QueryNode {
        return QueryNode(field: field, operation: .eq, dateValue: dateValue, formatter: formatter)
    }
    
    /// Phrase query or proximity search (matches) operator (mt) enables you to find words that are within a
    ///  specific distance to one another. Results are sorted by best match. It is useful for searching content
    ///  items when values given in the criteria “petrol 20kmpl” need to discover actual content that may
    ///  contain "petrol fuel mileage runs 20KMPL in the speed way".
    ///
    /// Matches operator also can use a wildcard within the given value and supports both single-character
    ///   and multiple-character wildcard searches within a single value. Use ? for a single-character
    ///   wildcard and * for multiple characters. Both “John” and “Joan” can be searched by “Jo?n” for a
    ///   single character and “Jo*” for multiple characters.
    ///
    /// This operator is applicable to both single-valued and multivalued data types. This operator does not
    ///   perform a search on stop words. Refer to Apache Lucene documentation to know more about stop words.
    ///   The value provided with this operator is not case-sensitive.
    ///
    /// Supported data types: text, largetext
    public class func match(field: String, value: String) -> QueryNode {
        return QueryNode(field: field, operation: .mt, stringValue: value)
    }
    
    /// Similarity query operator.
    ///
    /// This operator allows searching for values that sound like specified
    ///  criteria - also called fuzzy search, which uses by default a maximum of two edits to match the
    ///  result. “Rome” is similar to "Dome". This operator is applicable to both single-valued and
    ///  multivalued data types. The value provided with this operator is not case-sensitive.
    ///
    /// Supported data types: text, largetext
    public class func similar(field: String, value: String) -> QueryNode {
        return QueryNode(field: field, operation: .sm, stringValue: value)
    }
    
    /// Contains operator (co) matches every word given in the criteria.
    ///
    /// The words are formed by splitting
    ///  the value by special characters. It gives the results that have at least one of the words
    ///  (in this example, john or alex or both). This operator does not consider special characters in the
    ///  value while searching. This operator does not perform a search on stop words. Refer to Apache Lucene
    ///  documentation to know more about stop words.
    ///
    /// This operator is applicable to text, largetext in case of single-valued attributes, whereas for
    /// multivalued attributes, it is applicable to text, reference, number, decimal, datetime, largetext.
    /// To understand the possible datetime formats, refer to the Supported date/datetime formats (24Hrs)
    /// table. The value provided with this operator is not case-sensitive.
    ///
    /// Supported data types: text, reference, number, decimal, datetime, largetext
    public class func contains(field: String, value: String) -> QueryNode {
        return QueryNode(field: field, operation: .co, stringValue: value)
    }
    
    /// Contains operator (co) matches every word given in the criteria.
    public class func contains(field: String, dateValue: Date, formatter: DateFormatter) -> QueryNode {
        return QueryNode(field: field, operation: .co, dateValue: dateValue, formatter: formatter)
    }
    
    /// Contains operator (co) matches every word given in the criteria.
    public class func contains(field: String, intValue: Int) -> QueryNode {
        return QueryNode(field: field, operation: .co, intValue: intValue)
    }
    
    /// Contains operator (co) matches every word given in the criteria.
    public class func contains(field: String, doubleValue: Double) -> QueryNode {
        return QueryNode(field: field, operation: .co, doubleValue: doubleValue)
    }
    
    /// Starts With operator (sw) matches only the initial character values given in the field condition.
    /// This operator is not applicable to multivalued data types. The value provided with this operator
    /// is not case-sensitive.
    ///
    /// Supported data types: text
    public class func startsWith(field: String, value: String) -> QueryNode {
        return QueryNode(field: field, operation: .sw, stringValue: value)
    }
    
    /// Greater than or equal to operator (ge) matches only numeric and datetime values.
    /// To understand the possible datetime formats, refer to the Supported date/datetime formats (24Hrs) table.
    /// This operator is not applicable to multivalued data types.
    ///
    /// Supported data types: number, decimal, datetime
    public class func greaterThanOrEqual(field: String, intValue: Int) -> QueryNode {
        return QueryNode(field: field, operation: .ge, intValue: intValue)
    }
    
    /// Greater than or equal to operator (ge) matches only numeric and datetime values.
    public class func greaterThanOrEqual(field: String, doubleValue: Double) -> QueryNode {
        return QueryNode(field: field, operation: .ge, doubleValue: doubleValue)
    }
    
    /// Greater than or equal to operator (ge) matches only numeric and datetime values.
    public class func greaterThanOrEqual(field: String, dateValue: Date, formatter: DateFormatter) -> QueryNode {
        return QueryNode(field: field, operation: .ge, dateValue: dateValue, formatter: formatter)
    }
    
    /// Greater than operator (gt) matches only numeric and datetime values.
    /// To understand the possible datetime formats, refer to the Supported date/datetime formats (24Hrs) table.
    /// This operator is not applicable to multivalued data types.
    ///
    /// Supported data types: number, decimal, datetime
    public class func greaterThan(field: String, dateValue: Date, formatter: DateFormatter) -> QueryNode {
        return QueryNode(field: field, operation: .gt, dateValue: dateValue, formatter: formatter)
    }
    
    /// Greater than operator (gt) matches only numeric and datetime values.
    public class func greaterThan(field: String, intValue: Int) -> QueryNode {
        return QueryNode(field: field, operation: .gt, intValue: intValue)
    }
    
    /// Greater than operator (gt) matches only numeric and datetime values.
    public class func greaterThan(field: String, doubleValue: Double) -> QueryNode {
        return QueryNode(field: field, operation: .gt, doubleValue: doubleValue)
    }
    
    /// Less than or equal to operator (le) matches only numeric and datetime values.
    ///
    /// To understand the possible datetime formats, refer to the Supported date/datetime formats (24Hrs) table.
    /// This operator is not applicable to multivalued data types.
    ///
    /// Supported data types: number, decimal, datetime
    public class func lessThanOrEqual(field: String, intValue: Int) -> QueryNode {
        return QueryNode(field: field, operation: .le, intValue: intValue)
    }
    
    /// Less than or equal to operator (le) matches only numeric and datetime values.
    public class func lessThanOrEqual(field: String, doubleValue: Double) -> QueryNode {
        return QueryNode(field: field, operation: .le, doubleValue: doubleValue)
    }
    
    /// Less than or equal to operator (le) matches only numeric and datetime values.
    public class func lessThanOrEqual(field: String, dateValue: Date, formatter: DateFormatter) -> QueryNode {
        return QueryNode(field: field, operation: .le, dateValue: dateValue, formatter: formatter)
    }
    
    /// Less than operator (lt) matches only numeric and datetime values.
    ///
    /// To understand the possible datetime formats, refer to the Supported date/datetime formats (24Hrs) table.
    /// This operator is not applicable to multivalued data types.
    ///
    /// Supported data types: number, decimal, datetime
    public class func lessThan(field: String, intValue: Int) -> QueryNode {
        return QueryNode(field: field, operation: .lt, intValue: intValue)
    }
    
    /// Less than operator (lt) matches only numeric and datetime values.
    public class func lessThan(field: String, doubleValue: Double) -> QueryNode {
        return QueryNode(field: field, operation: .lt, doubleValue: doubleValue)
    }
    
    /// Less than operator (lt) matches only numeric and datetime values.
    public class func lessThan(field: String, dateValue: Date, formatter: DateFormatter) -> QueryNode {
        return QueryNode(field: field, operation: .lt, dateValue: dateValue, formatter: formatter)
    }
    
    /// Convenience method which allows the caller to provide formatted raw text which will be used for the query
    public class func queryText(value: String) -> QueryNode {
        return QueryNode(rawText: value)
    }
    
    /// Convenience method which allows a caller to specify that a single field should be queried
    /// to match any of the values specified
    ///
    /// For example:
    /// `matchList(field: "A", values: ["1", "2", "3"]`
    /// will produce an array of QueryNodes which themselves will produce a query of
    /// `(A eq "1" or A eq "2" or A eq "3")`
    public class func matchList(field: String, values: [String]) throws -> [QueryNode] {
        
        let returnNodes = try self.stringNodes(field: field, values: values)
        return returnNodes
    }
    
    /// Convenience method which allows a caller to specify that a single field should be queried
    /// to match any of the values specified
    public class func matchList(field: String, dateValues: [Date], formatter: DateFormatter) throws -> [QueryNode] {
        
        let returnNodes = try self.dateNodes(field: field, dateValues: dateValues, formatter: formatter)
        return returnNodes
    }
    
    /// Convenience method which allows a caller to specify that a single field should be queried
    /// to match any of the values specified
    public class func matchList(field: String, intValues: [Int]) throws -> [QueryNode] {
        
        let returnNodes = try self.intNodes(field: field, intValues: intValues)
        return returnNodes
    }
    
    /// Convenience method which allows a caller to specify that a single field should be queried
    /// to match any of the values specified
    public class func matchList(field: String, doubleValues: [Double]) throws -> [QueryNode] {
        
        let returnNodes = try self.doubleNodes(field: field, doubleValues: doubleValues)
        return returnNodes
    }
    
    /// Creates QueryNodes from the array of values passed in
    private class func stringNodes(field: String, values: [String]) throws -> [QueryNode] {
        let returnNodes: [QueryNode] = values.map { val in
            QueryNode(field: field, operation: .eq, stringValue: val)
        }
        
        if returnNodes.isEmpty {
            throw QueryBuilderError.emptyMatchList
        }
        
        return returnNodes
    }
    
    /// Creates QueryNodes from the array of values passed in
    private class func dateNodes(field: String, dateValues: [Date], formatter: DateFormatter) throws -> [QueryNode] {
        let returnNodes: [QueryNode] = dateValues.map { val in
            QueryNode(field: field, operation: .eq, dateValue: val, formatter: formatter)
        }
        
        return returnNodes
    }
    
    /// Creates QueryNodes from the array of values passed in
    private class func intNodes(field: String, intValues: [Int]) throws -> [QueryNode] {
        let returnNodes: [QueryNode] = intValues.map { val in
            QueryNode(field: field, operation: .eq, intValue: val)
        }
        
        return returnNodes
    }
    
    /// Creates QueryNodes from the array of values passed in
    private class func doubleNodes(field: String, doubleValues: [Double])throws -> [QueryNode] {
        let returnNodes: [QueryNode] = doubleValues.map { val in
            QueryNode(field: field, operation: .eq, doubleValue: val)
        }
        
        return returnNodes
    }
    
    /// Produce the actual query text for this particular node
    public func buildQueryString() -> String {
        
        var queryValue = ""
        
        switch self.nodeValue {
        case let .rawText(value):
            return value
            
        case let .date(date, formatter):
            queryValue = formatter.string(from: date)
            
        case let .string(value):
            queryValue = value
            
        case let .int(value):
            queryValue = String(value)
            
        case let .double(value):
            queryValue = String(value)
        }
        
        guard let fieldText = self.field,
            let operationText = self.operation?.rawValue else {
                return ""
        }
        
        return "\(fieldText) \(operationText) \"\(queryValue)\""
    }
}

extension QueryNode {
    /// Convenience method to build a query node for "In Review" status
    /// - returns QueryNode
    public class func inReviewStatus() -> QueryNode {
        return QueryNode.equal(field: "status", value: "inreview")
    }
        
    /// Convenience method to build a query node for "Approved" status
    /// - returns QueryNode
    public class func approvedStatus() -> QueryNode {
        return QueryNode.equal(field: "status", value: "approved")
    }
    
    /// Convenience method to build a query node for "Rejected" status
    /// - returns QueryNode
    public class func rejectedStatus() -> QueryNode {
        return QueryNode.equal(field: "status", value: "rejected")
    }
    
    /// Convenience method to build a query node for "Published" status
    /// - returns QueryNode
    public class func publishedStatus() -> QueryNode {
        return QueryNode.equal(field: "status", value: "published")
    }
    
    /// Convenience method to build a query node for "Translated" status
    /// - returns QueryNode
    public class func translatedStatus() -> QueryNode {
        return QueryNode.equal(field: "status", value: "translated")
    }
    
    /// Convenience method to build a query node for "Draft" status
    /// - returns QueryNode
    public class func draftStatus() -> QueryNode {
        return QueryNode.equal(field: "status", value: "draft")
    }
}
