// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import XCTest
import OracleContentCore
@testable import OracleContentTest

class CompositionalTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolMock.startURLOverride()
    }

    override func tearDownWithError() throws {
        URLProtocolMock.stopURLOverride()
    }
}

/// Override Tests
extension CompositionalTests {
    /// Validate the BaseURL without any builder options applied
   func testBaseURL() throws {
       let service = DummyTestingService<NoAssetPolling<NoAsset>>()

       XCTAssertEqual(
           service.url,
           URL(staticString: "http://localhost:2112/content/management/api/v1.1/dummytestingservice")
       )
   }
   
   /// Validate that overriding a URL results in a new service.url
   func testOverrideURL() throws {
    
       let service = DummyTestingService<NoAssetPolling<NoAsset>>().overrideURL(URL(staticString: "http://www.foo.com:8080"))
   
       XCTAssertEqual(service.url, URL(staticString: "http://www.foo.com:8080/content/management/api/v1.1/dummytestingservice"))
       
   }
   
   /// Validate that overriding a URL and supplying headers results in the correct URL
   /// and that the subsequent request contains the specified headers
   func testOverrideURLWithHeaders() throws {
       let url = URL(staticString: "http://www.foo.com:8080/content/management/api/v1.1/dummytestingservice")
       let headers = { return ["Foo": "bar", "phoo": "boo"] }
    
       let service = DummyTestingService<NoAssetPolling<NoAsset>>().overrideURL(url, authorizationHeaders: headers)
   
       XCTAssertEqual(service.url, URL(staticString: "http://www.foo.com:8080/content/management/api/v1.1/dummytestingservice"))
       
       let request = service.request?.allHTTPHeaderFields
          
       XCTAssertEqual(request?.count, 4)
       XCTAssertEqual(request?["X-Requested-With"], "XMLHttpRequest")
       XCTAssertEqual(request?["Content-Type"], "application/json")
       XCTAssertEqual(request?["Foo"], "bar")
       XCTAssertEqual(request?["phoo"], "boo")
       
   }
   
   /// Validate that an overridden URLSessionConfiguration is properly stored in the
   /// serviceParameters
   func testOverrideSessionConfiguration() throws {

       let config = URLSessionConfiguration.default
       config.httpAdditionalHeaders = ["Foo": "bar"]
    
       let service = DummyTestingService<NoAssetPolling<NoAsset>>().overrideSessionConfiguration(config)
       
       XCTAssertNotNil(service.serviceParameters?.overrideSessionConfiguration)
   }
   
   /// Validate that overriding to use the default session results ih CaaSRest.session.session() being used
   func testUseCacheSession() throws {

       let service = DummyTestingService<NoAssetPolling<NoAsset>>().useDefaultSession()
       
       XCTAssertNotNil(service.serviceParameters?.overrideSession)
       XCTAssertEqual(service.serviceParameters?.overrideSession?.sessionDescription,
                      Onboarding.sessions.session().sessionDescription)
       
   }
   
   /// Validate that overriding to use the no cache session results ih CaaSRest.session.noCacheSession() being used
   func testUseNoCacheSession() throws {

       let service = DummyTestingService<NoAssetPolling<NoAsset>>().useNoCacheSession()
       
       XCTAssertNotNil(service.serviceParameters?.overrideSession)
       XCTAssertEqual(service.serviceParameters?.overrideSession?.sessionDescription,
                      Onboarding.sessions.noCacheSession().sessionDescription)
   }
}

/// Channel Tokens
extension CompositionalTests {

    /// Validate that channel token is correctly populated
    func testChannelTokens() throws {
        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().channelToken("123")
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "channelToken" }?.value
        XCTAssertEqual(foundValue, "123")
        
    }
}

///// Sort Order
//extension CompositionalTests {
//
//    /// Validate that a standard field sort order is correctly populated
//    func testSortOrder_StandardField_Ascending() throws {
//        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().order(.)
//            .order(.standard("foo", .asc))
//
//        let components = sut.url.flatMap(obtainComponents)
//        let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
//        XCTAssertEqual(foundValue, "foo:asc")
//    }
//
//     /// Validate that a user field sort order is correctly populated
//    func testSortOrder_UserField_Ascending() throws {
//        let sut = DummyTestingService<NoAssetPolling<NoAsset>>()
//            .order(.user("bar", .asc))
//
//        let components = sut.url.flatMap(obtainComponents)
//        let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
//        XCTAssertEqual(foundValue, "fields.bar:asc")
//    }
//
//     /// Validate that a multiple fields sort order is correctly populated
//    func testSortOrder_MultipleFields_Descending() throws {
//
//        let sut = DummyTestingService<NoAssetPolling<NoAsset>>()
//            .order(.standard("foo", .asc), .user("bar", .desc))
//
//        let components = sut.url.flatMap(obtainComponents)
//        let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
//        XCTAssertEqual(foundValue, "foo:asc;fields.bar:desc")
//
//    }
//}
//
///// Limited Sort Order
//extension CompositionalTests {
//
//     /// Validate that a limited sort order is correctly populated
//    func testLimitedSortOrder_SingleValue_Ascending() throws {
//           let sut = DummyTestingService<NoAssetPolling<NoAsset>>()
//                .order(.name(.asc))
//
//           let components = sut.url.flatMap(obtainComponents)
//           let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
//           XCTAssertEqual(foundValue, "name:asc")
//       }
//
//     /// Validate that a limited sort order with multiple values is correctly populated
//       func testLimitedSortOrder_MultipleValues_Descending() throws {
//
//           let sut = DummyTestingService<NoAssetPolling<NoAsset>>()
//                .order(.name(.desc), .updatedDate(.desc))
//
//           let components = sut.url.flatMap(obtainComponents)
//           let foundValue = components?.queryItems?.first { $0.name == "orderBy" }?.value
//           XCTAssertEqual(foundValue, "name:desc;updatedDate:desc")
//
//       }
//}

/// Version tests
extension CompositionalTests {
     /// Validate that version is correctly populated
    func testVersion() throws {
        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().version(.v1_1)
        let components = sut.url.flatMap(obtainComponents)

        XCTAssertEqual(components?.path, "/content/management/api/v1.1/dummytestingservice")
    }
}

/// Listing Links tests
extension CompositionalTests {
    
     /// Validate that a listing link are correctly populated
    func testListingLinks() throws {
        let sut = ListingLinksService<NoAsset>().links(.canonical, .describedBy, .first, .last, .next, .prev, .selfLink)
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "links" }?.value
        XCTAssertEqual(foundValue, "canonical,describedBy,first,last,next,prev,self")
    }
}

/// Read Links tests
extension CompositionalTests {
     /// Validate that read links are correctly populated
    func testReadLinks() throws {
        let sut = ReadLinksService<NoAsset>().links(.canonical, .describedBy, .selfLink)
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "links" }?.value
        XCTAssertEqual(foundValue, "canonical,describedBy,self")
    }
}

/// Is Published Channel tests
extension CompositionalTests {
     /// Validate that isPublishedChannel is correctly populated
    func testIsPublishedChannel() throws {
        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().isPublishedChannel(true)
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "isPublishedChannel" }?.value
        XCTAssertEqual(foundValue, "true")
    }
}

/// Expand tests
extension CompositionalTests {
     /// Validate that expand = all is correctly populated
    func testExpand_All() throws {
        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().expand(.all)
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "expand" }?.value
        XCTAssertEqual(foundValue, "all")
    }
    
    /// Validate that expand with multiple fields is correctly populated
    func testExpand_Multiple() throws {
        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().expand("foo", "fields.bar")
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "expand" }?.value
        XCTAssertEqual(foundValue, "foo,fields.bar")
    }
}

/// Total Results tests
extension CompositionalTests {
    /// Validate that total results are correctly populated
    func testTotalResults() throws {
        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().totalResults(true)
        let components = sut.url.flatMap(obtainComponents)
        let foundValue = components?.queryItems?.first { $0.name == "totalResults" }?.value
        XCTAssertEqual(foundValue, "true")
    }
}

/// AdditionalHeaders tests
extension CompositionalTests {
    
    func testAdditionalHeaders() throws {
        let firstExpectedValue = "firstValue"
        let secondExpectedValue = "secondValue"
        
        let sut = DummyTestingService<NoAssetPolling<NoAsset>>().additionalHeaders([ "firstKey": firstExpectedValue, "secondKey": secondExpectedValue])
        let request = try XCTUnwrap(sut.request)
        let value = try XCTUnwrap(request.value(forHTTPHeaderField: "firstKey"))
        XCTAssertEqual(value, firstExpectedValue)
        
        let value2 = try XCTUnwrap(request.value(forHTTPHeaderField: "secondKey"))
        XCTAssertEqual(value2, secondExpectedValue)
    }
}

