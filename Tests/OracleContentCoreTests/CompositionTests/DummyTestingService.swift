// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

public final class DummyTestingService<Element: Decodable & SupportsPolling>:
                                                 BaseService<Element>,
                                                 ImplementsFetchListing,
                                                 ImplementsFetchDetail,
                                                 ImplementsIsPublishedChannel,
                                                 ImplementsOverrides,
                                                 ImplementsChannelToken,
                                                 ImplementsVersion,
                                                 ImplementsLinks,
                                                 ImplementsExpand,
                                                 ImplementsTotalResults,
                                                 ImplementsAdditionalHeaders {
    
    public typealias DecodableElement = Element
    public typealias ServiceSpecificParameters = DummyTestingServiceParameters
    public typealias ServiceReturnType = DummyTestingService<Element>
    public typealias LinksValuesConstructor = ListingLinksValues
    
    public required override init() {
        super.init()
        self.serviceParameters = ServiceSpecificParameters()
    }
}

public final class ListingLinksService<Element: Decodable>: BaseService<Element>,
                                                      ImplementsLinks {
    
    public typealias DecodableElement = Element
    public typealias ServiceSpecificParameters = DummyTestingServiceParameters
    public typealias ServiceReturnType = ListingLinksService<Element>
    public typealias LinksValuesConstructor = ListingLinksValues
    
    public required override init() {
        super.init()
        self.serviceParameters = ServiceSpecificParameters()
    }
}

public final class ReadLinksService<Element: Decodable>: BaseService<Element>,
                                                   ImplementsLinks {
    
    public typealias DecodableElement = Element
    public typealias ServiceSpecificParameters = DummyTestingServiceParameters
    public typealias ServiceReturnType = ReadLinksService<Element>
    public typealias LinksValuesConstructor = ReadLinksValues
    
    public required override init() {
        super.init()
        self.serviceParameters = ServiceSpecificParameters()
    }
}

public class DummyTestingServiceParameters: ServiceParameters {
   
    override init() {
        super.init()
        self.basePath = LibraryPathConstants.baseManagementPath
    }

    public override var serviceSuffix: String { "dummytestingservice" }

}
