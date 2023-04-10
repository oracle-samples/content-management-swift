// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Determines whether OperationNodes should be wrapped in parentheses
public enum QueryBuilderGrouping: Int {
    case none
    case grouped
}

public enum QueryBuilderError: Error {
    case emptyMatchList
}

/// User-facing class which is used to build a query operation
public class QueryBuilder: NSObject, QueryToString {
    
    internal var root: OperationNode?
    
    /// Create a NodeBuilder with an initial query value
    public init(node: QueryNode) {
        self.root = OperationNode(value: node.buildQueryString())
    }
    
    /// Create a NodeBuilder with an initial match list
    @nonobjc
    public init(matchList: [QueryNode]) throws {
        
        guard let firstNode = matchList.first else {
            throw QueryBuilderError.emptyMatchList
        }
        
        var builder = QueryBuilder(node: firstNode)
        
        for index in 1 ..< matchList.count {
            builder = builder.or(matchList[index])
        }
        
        builder.root?.grouping = .grouped
        
        self.root = builder.root
        
    }
    
    /// Append the specified node to the query and apply a Boolean AND operation with it
    /// Specify that the entire subquery should be wrapped in parentheses by passing .grouped to
    /// the grouping parameter
    public func and(_ node: QueryNode, grouping: QueryBuilderGrouping = .none) -> QueryBuilder {
        let opNode = OperationNode(value: node.buildQueryString())
        let newRoot = OperationNode(operation: .and, lhs: self.root, rhs: opNode, grouping: grouping)
        self.root = newRoot
        return self
    }
    
    /// Append the specified builder to the query and apply a Boolean AND operation with it
    /// Specify that the entire subquery should be wrapped in parentheses by passing .grouped to
    /// the grouping parameter
    public func and(builder: QueryBuilder, grouping: QueryBuilderGrouping = .none) -> QueryBuilder {
        
        let temp = self.root
        let newRoot = OperationNode(operation: .and, lhs: temp, rhs: builder.root, grouping: grouping)
        self.root = newRoot
        return self
        
    }
    
    /// Append the specified matchList to the query and apply a Boolean AND operation with it
    /// Specify that the entire subquery should be wrapped in parentheses by passing .grouped to
    /// the grouping parameter
    @nonobjc
    public func and(matchList: [QueryNode]) throws -> QueryBuilder {
        
        guard let foundItem = matchList.first else {
            throw QueryBuilderError.emptyMatchList
        }
        
        var builder = QueryBuilder(node: foundItem)
        
        for index in 1 ..< matchList.count {
            builder = builder.or(matchList[index])
        }
        
        builder.root?.grouping = .grouped
        
        let temp = self.root
        let newRoot = OperationNode(operation: .and, lhs: temp, rhs: builder.root, grouping: .grouped)
        self.root = newRoot
        return self
    }
    
    /// Append the specified builder to the query and apply a Boolean OR operation with it
    /// Specify that the entire subquery should be wrapped in parentheses by passing .grouped to
    /// the grouping parameter
    public func or(builder: QueryBuilder, grouping: QueryBuilderGrouping = .none) -> QueryBuilder {
        let temp = self.root
        let newRoot = OperationNode(operation: .or, lhs: temp, rhs: builder.root, grouping: grouping)
        self.root = newRoot
        return self
    }
    
    /// Append the specified node to the query and apply a Boolean OR operation with it
    /// Specify that the entire subquery should be wrapped in parentheses by passing .grouped to
    /// the grouping parameter
    public func or(_ node: QueryNode, grouping: QueryBuilderGrouping = .none) -> QueryBuilder {
        let opNode = OperationNode(value: node.buildQueryString())
        let newRoot = OperationNode(operation: .or, lhs: self.root, rhs: opNode, grouping: grouping)
        self.root = newRoot
        return self
    }
    
    /// Produce the string to be used as the query parameter
    public func buildQueryString() -> String {
        return root?.queryText() ?? ""
    }
    
}
