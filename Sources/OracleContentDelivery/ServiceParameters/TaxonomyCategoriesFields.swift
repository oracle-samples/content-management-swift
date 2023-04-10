// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

/**
 The fields parameter is used to control the returned fields and values in the queried category.
 
 [See query parameters in online documentation](https://docs.oracle.com/en/cloud/paas/content-cloud/rest-api-content-delivery/op-published-api-v1.1-taxonomies-id-categories-categoryid-get.html#request-query-param-fields)
 
 Additional fields not included by default in the response:
 * **keywords**: A comma-separated list of values assigned to the keywords system managed category property.
 * **synonyms**: A comma-separated list of values assigned to the synonyms system managed category property.
 * **relatedCategories**: A list where each element represents a category that is related to the current category. Note that this field only shows the categories published to the same channel as the current category.
 * **customProperties**: Category property values for the user defined category properties. Note that this field only shows the category property values of the publishable category properties.
 */
public enum TaxonomyCategoriesFieldType: String, Hashable, CaseIterable {
    case keywords
    case synonyms
    case relatedCategories
    case customProperties
    case all
    
    internal func queryValue() -> String? {
        return self.rawValue
    }
}

/**
 Structure used by the service class to identify the user-specified fields to include in the result. The primary purpose of this structure is to build the `URLQueryItem` that is used to populate the service's URL.
 */
public struct TaxonomyCategoriesFieldValues: AllowableFieldsValuesConstructor {
    
    public typealias ValueType = TaxonomyCategoriesFieldType
    
    private var values = [ValueType]()
    
    public init(_ values: [ValueType] = [] ) {
        self.values = values
    }
}

extension TaxonomyCategoriesFieldValues: ConvertToURLQueryItem {
    
    static public var keyValue: String {
        "fields"
    }
    
    public var queryItem: URLQueryItem? {
        
        var item: URLQueryItem?
        
        if self.containsAllValue() {
            item = URLQueryItem(name: FieldValues.keyValue, value: FieldType.all.queryValue())
        } else {
            let stringValues = self.values.compactMap { $0.queryValue() }
            let separatedValues = stringValues.joined(separator: ",")
            
            if !separatedValues.isEmpty {
                item = URLQueryItem(name: FieldValues.keyValue, value: separatedValues)
            }
            
        }
        
        return item
    }
    
}

extension TaxonomyCategoriesFieldValues {
    private func containsAllValue() -> Bool {
        return self.values.contains { element in
            if case .all = element {
                return true
            }
            return false
        }
    }
}

