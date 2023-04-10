// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
@testable import OracleContentCore

internal class QueryTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
       
    }
}

/// Simple queries 
extension QueryTests {
    func testRawQuery() {
        let initialNode = QueryNode.queryText(value: "(A eq \"1\" and B eq \"2\")")
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "(A eq \"1\" and B eq \"2\")"
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A eq 1
    func testEqualString() {
        let initialNode = QueryNode.equal(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A eq 1 (as int)
    func testEqualInt() {
        let initialNode = QueryNode.equal(field: "A", intValue: 1)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A eq 1.234 (as Double)
    func testEqualDouble() {
        let initialNode = QueryNode.equal(field: "A", doubleValue: 1.234)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1.234\""
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A co "1970/12/365"
    func testEqualDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "YYYY/MM/DD"
        let date = Date(timeIntervalSince1970: 0)
        
        let initialNode = QueryNode.equal(field: "A", dateValue: date, formatter: dateFormatter)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1970/01/01\""
        XCTAssertEqual(queryText, expected)
    }
    /// Validates A co "1" (as string)
    func testContainsString() {
        let initialNode = QueryNode.contains(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A co \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    /// Validates A co "1" (as int)
    func testContainsInt() {
        let initialNode = QueryNode.contains(field: "A", intValue: 1)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A co \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    /// Validates A co "1.234" (as double)
    func testContainsDouble() {
        let initialNode = QueryNode.contains(field: "A", doubleValue: 1.234)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A co \"1.234\""
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A co "1970/12/365"
    func testContainsDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/DD"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") 
        let date = Date(timeIntervalSince1970: 0)
        
        let initialNode = QueryNode.contains(field: "A", dateValue: date, formatter: dateFormatter)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A co \"1970/01/01\""
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A sw "1"
    func testStartsWith() {
        let initialNode = QueryNode.startsWith(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A sw \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testGreaterThanEqualInt() {
        let initialNode = QueryNode.greaterThanOrEqual(field: "A", intValue: 1)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A ge \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testGreaterThanEqualDouble() {
        let initialNode = QueryNode.greaterThanOrEqual(field: "A", doubleValue: 1.234)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A ge \"1.234\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testGreaterThanEqualDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/DD"
        let date = Date(timeIntervalSince1970: 0)
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        let initialNode = QueryNode.greaterThanOrEqual(field: "A", dateValue: date, formatter: dateFormatter)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A ge \"1970/01/01\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testLessThanEqualInt() {
        let initialNode = QueryNode.lessThanOrEqual(field: "A", intValue: 1)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A le \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testLessThanEqualDouble() {
        let initialNode = QueryNode.lessThanOrEqual(field: "A", doubleValue: 1.234)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A le \"1.234\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testLessThanEqualDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/DD"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") 
        let date = Date(timeIntervalSince1970: 0)
        
        let initialNode = QueryNode.lessThanOrEqual(field: "A", dateValue: date, formatter: dateFormatter)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A le \"1970/01/01\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testGreaterThanInt() {
        let initialNode = QueryNode.greaterThan(field: "A", intValue: 1)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A gt \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testGreaterThanDouble() {
        let initialNode = QueryNode.greaterThan(field: "A", doubleValue: 1.234)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A gt \"1.234\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testGreaterThanDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "YYYY/MM/DD"
        let date = Date(timeIntervalSince1970: 0)
        
        let initialNode = QueryNode.greaterThan(field: "A", dateValue: date, formatter: dateFormatter)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A gt \"1970/01/01\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testLessThanInt() {
        let initialNode = QueryNode.lessThan(field: "A", intValue: 1)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A lt \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testLessThanDouble() {
        let initialNode = QueryNode.lessThan(field: "A", doubleValue: 1.234)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A lt \"1.234\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testLessThanDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "YYYY/MM/DD"
        let date = Date(timeIntervalSince1970: 0)
        
        let initialNode = QueryNode.lessThan(field: "A", dateValue: date, formatter: dateFormatter)
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A lt \"1970/01/01\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testMatch() {
        let initialNode = QueryNode.match(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A mt \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testSimilar() {
        let initialNode = QueryNode.similar(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
        let queryText = sut.buildQueryString()
        let expected = "A sm \"1\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testInReview() {
        let node = QueryNode.inReviewStatus()
        let sut = QueryBuilder(node: node)
        let queryText = sut.buildQueryString()
        let expected = "status eq \"inreview\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testApproved() {
        let node = QueryNode.approvedStatus()
        let sut = QueryBuilder(node: node)
        
        let queryText = sut.buildQueryString()
        let expected = "status eq \"approved\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testRejected() {
        let node = QueryNode.rejectedStatus()
        let sut = QueryBuilder(node: node)
        let queryText = sut.buildQueryString()
        let expected = "status eq \"rejected\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testTranslated() {
        let node = QueryNode.translatedStatus()
        let sut = QueryBuilder(node: node)
        let queryText = sut.buildQueryString()
        let expected = "status eq \"translated\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testDraft() {
        let node = QueryNode.draftStatus()
        let sut = QueryBuilder(node: node)
        let queryText = sut.buildQueryString()
        let expected = "status eq \"draft\""
        XCTAssertEqual(queryText, expected)
    }

}

/// Compound Queries
extension QueryTests {
    // validates (A eq 1 or A eq 2 or A eq 3)
    func testMatchList() throws {
        
        let nodes = try QueryNode.matchList(field: "A", values: ["1", "2", "3"])
        
        let sut = try QueryBuilder(matchList: nodes)
    
        let queryText = sut.buildQueryString()
        let expected = "(A eq \"1\" or A eq \"2\" or A eq \"3\")"
        XCTAssertEqual(queryText, expected)
    }
    
    func testQueryNodeWithEmptyValues() throws {
        
        XCTAssertThrowsError(try QueryNode.matchList(field: "A", values: [])) { error in
            XCTAssertTrue(error.matchesError(QueryBuilderError.emptyMatchList))
        }
    }
    
    func testQueryBuilderWithEmptyMatchList() throws {
        XCTAssertThrowsError(try QueryBuilder(matchList: [])) { error in
            XCTAssertTrue(error.matchesError(QueryBuilderError.emptyMatchList))
        }
    }
    
    // An empty matchList will cause the entire query string to be blank
    func testEmptyMatchListWithAppend() throws {
        XCTAssertThrowsError(try QueryBuilder(matchList: [])
                                    .and(QueryNode.equal(field: "B", value: "4"))) { error in
            XCTAssertTrue(error.matchesError(QueryBuilderError.emptyMatchList))
        }
    }
    
    // validates (A eq 1 or A eq 2 or A eq 3) and B eq 4
    func testAppendToMatchList() throws {
        let nodes = try QueryNode.matchList(field: "A", values: ["1", "2", "3"])
        
        let sut = try QueryBuilder(matchList: nodes)
                        .and(QueryNode.equal(field: "B", value: "4"))
        
        let queryText = sut.buildQueryString()
        let expected = "(A eq \"1\" or A eq \"2\" or A eq \"3\") and B eq \"4\""
        XCTAssertEqual(queryText, expected)
    }
    
    // validates ((A eq 1 or A eq 2 or A eq 3) and B eq 4) or C eq 5
    func testAppendToMatchListWithGrouping() throws {
        let nodes = try QueryNode.matchList(field: "A", values: ["1", "2", "3"])
        
        let sut = try QueryBuilder(matchList: nodes)
                        .and(QueryNode.equal(field: "B", value: "4"), grouping: .grouped)
                        .or(QueryNode.equal(field: "C", value: "5"))
        
        let queryText = sut.buildQueryString()
        let expected = "((A eq \"1\" or A eq \"2\" or A eq \"3\") and B eq \"4\") or C eq \"5\""
        XCTAssertEqual(queryText, expected)
    }
    
    func testBuilderWithParens() {
        let initialNode1 = QueryNode.equal(field: "A", value: "1")
        
        let initialNode2 = QueryNode.equal(field: "B", value: "2")
        let sut2 = QueryBuilder(node: initialNode2)
            .or(QueryNode.equal(field: "C", value: "3"), grouping: .grouped)
        
        let sut = QueryBuilder(node: initialNode1)
            .and(builder: sut2)
        
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1\" and (B eq \"2\" or C eq \"3\")"
        XCTAssertEqual(queryText, expected)
    }
    // Validates A eq 1 and B eq 2
    func testCompoundAnd() {
        let initialNode = QueryNode.equal(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
            .and(QueryNode.equal(field: "B", value: "2"))
        
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1\" and B eq \"2\""
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A eq 1 or B eq 2
    func testCompoundOr() {
        let initialNode = QueryNode.equal(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
            .or(QueryNode.equal(field: "B", value: "2"))
        
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1\" or B eq \"2\""
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates (A eq 1 and B eq 2)
    func testCompoundAndWithParens() {
        let initialNode = QueryNode.equal(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
            .and(QueryNode.equal(field: "B", value: "2"), grouping: .grouped)
        
        let queryText = sut.buildQueryString()
        let expected = "(A eq \"1\" and B eq \"2\")"
        XCTAssertEqual(queryText, expected)
    }
    
    // Validates A eq 1 and B eq 2 and C eq 3 or 1 eq XXX or 2 eq YYY and D 4
    func testMultipleAndsAndOrs() {
        let initialNode = QueryNode.equal(field: "A", value: "1")
        let sut = QueryBuilder(node: initialNode)
            .and(QueryNode.equal(field: "B", value: "2"))
            .and(QueryNode.equal(field: "C", value: "3"))
            .or(QueryNode.equal(field: "1", value: "XXX"))
            .or(QueryNode.equal(field: "22", value: "YYY"))
            .and(QueryNode.equal(field: "D", value: "4"))
        
        let queryText = sut.buildQueryString()
        let expected = "A eq \"1\" and B eq \"2\" and C eq \"3\" or 1 eq \"XXX\" or 22 eq \"YYY\" and D eq \"4\""
        XCTAssertEqual(queryText, expected)
    }
}
