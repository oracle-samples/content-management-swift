// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore 

/**
 Retrieve a list of published assets using the Delivery SDK.
 */
public final class ListAssets<Element: Decodable>: BaseService<Element>,
                                             ImplementsFetchListing,
                                             ImplementsSortOrder,
                                             ImplementsOverrides,
                                             ImplementsChannelToken,
                                             ImplementsVersion,
                                             ImplementsIsPublishedChannel,
                                             ImplementsFields,
                                             ImplementsTotalResults {
    
    internal typealias ServiceSpecificParameters    = ListAssetsParameters
    public typealias ServiceReturnType              = ListAssets<Element>
    public typealias FieldValuesConstructor         = FieldValues
    public typealias SortOrderValuesConstructor     = SortOrderValues<AssetsSortOrderType>
    
    public required override init() {
        super.init()
        self.serviceParameters = ServiceSpecificParameters()
    }
    
    /**
    Provide a query to limit the results returned.
    
    - parameter queryBuilder: An object that can provide a formatted string query. The most typical value supplied to this parameter will be a `QueryBuilder` object that can create query strings of varying complexity
    - returns: `ListAssets`
    
    See QueryTests unit tests for examples on how to create queries

     This parameter accepts a query expression condition that matches the field values. Many such query conditions can be joined using AND/OR operators and grouped with parentheses. The value of query condition follows the format of {fieldName} {operator} “{fieldValue}”.
     
     In case of queries across type the field names are limited to standard fields
     (id, type, name, description, slug, language, createdDate, updatedDate, taxonomies).
     
     However in case of type specific query the field names are limited to standard fields and user defined fields (except fields of largeText data type). The only values allowed in the operator are eq (Equals), co (Contains), sw (Startswith), ge (Greater than or equals to), le (Less than or equals to), gt (Greater than), lt (Less than), mt (Matches), sm (Similar).
    */
    public func query(_ queryBuilder: QueryToString) -> ListAssets<Element> {
        let queryParameter = QueryParameter.value(queryBuilder)
        self.addParameter(key: QueryParameter.keyValue, value: queryParameter)
        return self
    }
    
    public func query(rawText: String) -> ListAssets<Element> {
        let queryParameter = QueryParameter.rawText(rawText)
        self.addParameter(key: QueryParameter.keyValue, value: queryParameter)
        return self
    }
    
    /**
    Default search query expression, that matches values of the items across all fields.
     
     - parameter values: An array of string values
    */
    public func defaultQuery(_  values: String...) -> ListAssets<Element> {
        let queryParameter = DefaultQueryValues(values)
        self.addParameter(key: DefaultQueryValues.keyValue, value: queryParameter)
        return self
    }
}

internal class ListAssetsParameters: SimpleDeliveryParameters {
   
    override init() {
        super.init()
        self.parameters = [
            OffsetParameter.keyValue: OffsetParameter.value(0),
            LimitParameter.keyValue: LimitParameter.value(100),
            TotalResultsParameter.keyValue: TotalResultsParameter.value(true)
        ]
    }

    public override var serviceSuffix: String { "items" }

}

