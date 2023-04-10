// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Internal class representing the text which prints for an individual node
/// Contains references to child left and right nodes
/// Parenthetical operations are controlled by the "grouping" property
internal class OperationNode {
    internal var operation: BoolOperations?
    var grouping: QueryBuilderGrouping = .none
    var value: String?
    var left: OperationNode?
    var right: OperationNode?
    
    /// Create an endpoint node.
    /// Note that endpoints like:
    ///    A eq "1"
    /// cannot be wrapped in parentheses.
    /// Parentheses can only be used to wrap the left and right child nodes
    /// - parameter value: The text value that should be used as the query
    internal init(value: String) {
        self.operation = nil
        self.value = value
        self.left = nil
        self.right = nil
    }
    
    /// Create a node specifying the Boolean operation that governs the relationship between two nodes
    /// - parameter operation: A BoolOperations value (.and/.or)
    /// - parameter lhs: OperationNode?
    /// - parameter rhs: OperationNode?
    /// - parameter grouping: NodeBuilderGroup. Determines whether to wrap the entire node in parentheses
    ///   For example if:
    ///   operation = .or
    ///   left = A eq 1
    ///   right = B eq 2
    ///   Then
    ///   grouping = .none produces A eq 1 or B eq 2
    ///   grouping = .grouped produces (A eq 1 or B eq 2)
    internal init(operation: BoolOperations, lhs: OperationNode?, rhs: OperationNode?, grouping: QueryBuilderGrouping) {
        self.operation = operation
        self.grouping = grouping
        self.value = nil
        self.left = lhs
        self.right = rhs
    }
    
    /// Produces the final query text for the given node by
    /// obtaining the query text for all left and right children
    /// - returns: String representing the query text to use
    internal func queryText() -> String {
        
        if let foundValue = self.value {
            return foundValue
        } else {
            guard let operationText = self.operation?.rawValue,
                let lhsText = self.left?.queryText(),
                let rhsText = self.right?.queryText() else {
                    return ""
            }
            
            let openParen = self.grouping == .grouped ? "(" : ""
            let closeParen = self.grouping == .grouped ? ")" : ""
            
            return  openParen + lhsText + " " + operationText + " " + rhsText + closeParen
        }
    }
}
