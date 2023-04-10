# Using Other Transport Methods

The Delivery library can create URLs and requests for you to use with your own transport system. Find out how you can use the Delivery library alongside your current service methodology.

## Overview

While the Delivery library offers the ability to submit service calls through available **invocation verbs**, you may already be heavily invested in some other transport methodolgy, like Alamofire. You can easily use the Delivery library to build a URLRequest and parse results for services submitted "outside" the library.

## Service Information
Before you can manually submit a service and decode its results, you need to know the model object that the service is producing.

Let's say you want to "list" the assets in a particular channel. In the `Interfaces` folder of the library, you will see all of the service definitions available. In this case, because we are listing assets, we look to the file `DeliveryAPI+Assets.swift`.

In that file we see the following function signature: 
```swift
public class func listAssets() -> ListAssets<Assets>
```

Notice that the return type of this function is the actual service (``ListAssets``) which is generic over the ``Assets`` model type. This means that after a successful service call, you will receive an ``Assets`` model object containing the values retrieved.

## Transforming the Service Response 
Now that you know what type of model object you will receive, you'll need to use a DeliveryAPI helper function to transform the raw data.

That helper function is: 
``DeliveryAPI/decode(type:from:response:)``

One implementation in a pipeline might be to do this: 
```swift 
.tryCompactMap {
    // decode into an Assets model object or throw an OracleContentError
    try DeliveryAPI.decode(type: Assets.self, from: $0.data, response: $0.response)
}
```

## Example using URLSession's dataTaskPublisher
```swift 
import OracleContentCore
import OracleContentDelivery 
import Combine 

var cancellables = [AnyCancellable]()
let url = URL(string: "https://your-ocm-instance")!
let token = "your-channel-token"

// build your service as you normally would and obtain the URLRequest
// note: If you configured the URLProvider as part of the Onboarding process, the override URL and channel token builder components would not be necessary
let service = DeliveryAPI.listAssets()
                         .overrideURL(url)
                         .channelToken(token)

guard let request = service.request else { 
    // handle error here
    return 
}

var c: AnyCancellable?

c = URLSession.shared
   .dataTaskPublisher(for: request)
   .tryCompactMap {
      // decode into an Assets model object or throw an OracleContentError
       try DeliveryAPI.decode(type: Assets.self, from: $0.data, response: $0.response)
   }
   .receive(on: RunLoop.main)
   .sink { completion in

      // handle completion - see "Handling Completion" below
      self.cancellables.removeAll { $0 === c }

   } receiveValue: { assets in

      // do something with assets
   }

c?.store(in: &self.cancellables)

```

## Example using Alamofire 
```swift 
   import Alamofire
   import OracleContentCore
   import OracleContentDelivery 
   import Combine 

   let url = URL(string: "https://your-ocm-instance")!
   let token = "your-channel-token"

   // build your service as you normally would and obtain the URLRequest
   // note: If you configured the URLProvider as part of the Onboarding process, the override URL and channel token builder components would not be necessary
   let service = DeliveryAPI.listAssets()
                            .overrideURL(url)
                            .channelToken(token)

   guard let request = service.request else { 
      // handle error here
      return 
   }
   
   var c: AnyCancellable?
   c = AF.request(request)
      .publishData()
      .tryCompactMap {
         // decode into an Assets model object or throw an OracleContentError
         try DeliveryAPI.decode(type: Assets.self, from: $0.data, response: $0.response)
      }
      .sink(receiveCompletion: { completion in

          // handle completion - see "Handling Completion" below
          self.cancellables.removeAll { $0 === c }

      }, receiveValue: { assets in

          // do something with assets
      })
   
   c?.store(in: &self.cancellables)

```

## Handling Completion 
When the pipeline finishes and the `receiveCompletion` closure is called, you need to handle any errors that were received. All library errors are of type `OracleContentError`.

All `OracleContentError` objects expose a `localizedDescription` property.

All `OracleContentError` objects expose a `serverStatusCode` property which returns an optional `Int`. Errors which are created as a result of server responses will contain the httpStatusCode of the reponse 

All `OracleContentError` objects expose a `jsonResponse` property and a `jsonString()` method. Errors which are created as a result of server responses will contain the information returned in the web service body, encoded to a `JSONValue` object. The `jsonResponse` property will give access to the structured data that was returned while the `jsonString()` method will return the string representation of that structure. 

```swift 
  switch completion { 
  case .failure(let error):
     print(error.localizedDescription)
  
     if let serverStatusCode = (error as? OracleContentError)?.serverStatusCode {
        print("Server Status Code: \(serverStatusCode)")
     }
  
     if let jsonResponse = (error as? OracleContentError)?.jsonValue {
        print("JSONValue: \(jsonResponse)")
        print("JSONString: \(jsonResponse.jsonString())")
     }
   default: 
      break
  }

```


