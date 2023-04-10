// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore

/*!
Retrieve a list of taxonomy categories
 */
public final class ListTaxonomyCategories<Element: Decodable>: BaseService<Element>,
                                                 ImplementsFetchListing,
                                                 ImplementsOverrides,
                                                 ImplementsChannelToken,
                                                 ImplementsSortOrder,
                                                 ImplementsVersion,
                                                 ImplementsLinks,
                                                 ImplementsExpand,
                                                 ImplementsTotalResults {
    
    public typealias DecodableElement           = Element
    internal typealias ServiceSpecificParameters  = ListTaxomomyCategoriesParameters
    public typealias ServiceReturnType          = ListTaxonomyCategories<Element>
    public typealias LinksValuesConstructor     = ListingLinksValues
    public typealias SortOrderValuesConstructor = SortOrderValues<TaxomomyCategorySortOrderType>
    
    public required init(taxonomyId: String) {
        super.init()
        self.serviceParameters = ServiceSpecificParameters(taxonomyId: taxonomyId)
    }
}

internal class ListTaxomomyCategoriesParameters: SimpleDeliveryParameters {
   
    private var taxonomyId: String = "<unspecified>"
    
    public init(taxonomyId: String) {
        super.init()
        
        self.taxonomyId = taxonomyId
        
        self.parameters = [
            OffsetParameter.keyValue: OffsetParameter.value(0),
            LimitParameter.keyValue: LimitParameter.value(100),
            TotalResultsParameter.keyValue: TotalResultsParameter.value(true)
        ]
    }

    public override var serviceSuffix: String { "taxonomies/\(self.taxonomyId)/categories" }

}
