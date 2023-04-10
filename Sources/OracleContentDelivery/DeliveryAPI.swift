// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

/**
 The REST API for Content Delivery provides access to published contents in Oracle Content and Experience Cloud.

 ### Namespacing
 `DeliveryAPI` represents the namespace for all services in the Delivery library.
 
 **Available services are defined in the following locations:**
 - DeliveryAPI+Items
 - DeliveryAPI+Taxonomies
 - DeliveryAPI+Download

 Uptaking code will refefence a service by typing:
 ```
 let service = DeliveryAPI.<service>
 ```
 All available services should be available via code completion
 
 ### Invocation Options
 Most services are callable either in completion handler, Future or async form:

### Swift Completion Handler Usage Example:
````
 
 let search = DeliveryAPI.listAssets()

 search.fetchNext { result in
    // handler code
 }
````
### Swift Future Usage Example: ###
````

 let search = DeliveryAPI.listAssets()
 
 let cancellable = search
                    .fetchNext()
                    .map { /* handler */ }
                    .sink { /* handler */ }

````
### Swift Async Usage Example: ###
```swift
 let search = DeliveryAPI.listAssets()
 let listing = try await service.fetchNext()
                                                        
```
*/
public class DeliveryAPI { }
    
extension DeliveryAPI {
    public class func data(from data: Data?, response: URLResponse?) throws -> Data {
        return try ResultFromResponse.data(from: data, response: response as? HTTPURLResponse)
    }
    
    public class func decode<Element: Decodable>(type: Element.Type, from data: Data?, response: URLResponse?) throws -> Element {
        let data = try Self.data(from: data, response: response as? HTTPURLResponse)
        let element = try LibraryJSONDecoder().decode(Element.self, from: data)
        return element
    }
}
