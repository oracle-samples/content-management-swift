// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public enum QueryParameter {
    
    case value(QueryToString)
}

extension QueryParameter: ConvertToURLQueryItem {
    public static var keyValue: String {
        return "q"
    }
    
    public var queryItem: URLQueryItem? {
        guard case QueryParameter.value(let query) = self else {
            return nil
        }
        
        let queryString = query.buildQueryString()
        return URLQueryItem(name: QueryParameter.keyValue, value: queryString)
    }
    
    public static func rawText(_ rawText: String) -> QueryParameter {
        let initialNode = QueryNode.queryText(value: rawText)
        let queryBuilder = QueryBuilder(node: initialNode)
        return QueryParameter.value(queryBuilder)
    }
}
