// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import OracleContentCore

/**
 Retrieves a list of taxonomies
 */
public final class ListTaxonomies<Element: Decodable>: BaseService<Element>,
                                                 ImplementsFetchListing,
                                                 ImplementsOverrides,
                                                 ImplementsChannelToken,
                                                 ImplementsSortOrder,
                                                 ImplementsVersion,
                                                 ImplementsLinks,
                                                 ImplementsExpand,
                                                 ImplementsTotalResults,
                                                 ImplementsAdditionalHeaders {
    
    public typealias DecodableElement           = Element
    internal typealias ServiceSpecificParameters  = ListTaxomomiesParameters
    public typealias ServiceReturnType          = ListTaxonomies<Element>
    public typealias LinksValuesConstructor     = ListingLinksValues
    public typealias SortOrderValuesConstructor = SortOrderValues<TaxomomySortOrderType>
    
    public required override init() {
        super.init()
        self.serviceParameters = ServiceSpecificParameters()
    }
}

internal class ListTaxomomiesParameters: SimpleDeliveryParameters {
   
    override init() {
        super.init()
        self.parameters = [
            OffsetParameter.keyValue: OffsetParameter.value(0),
            LimitParameter.keyValue: LimitParameter.value(100),
            TotalResultsParameter.keyValue: TotalResultsParameter.value(true)
        ]
    }

    public override var serviceSuffix: String { "taxonomies" }

}
