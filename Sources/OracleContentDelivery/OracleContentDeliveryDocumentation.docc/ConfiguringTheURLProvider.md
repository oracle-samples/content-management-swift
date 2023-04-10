# Configuring the URLProvider

Provide information to the library detailing the base URL, additional headers and default channel token.

## Overview

The URLProvider protocol defines three variables. The type of each variable is a function that takes no parameters and returns a different type of result.

#### Implementation Steps 
- Create a class that conforms to the `OracleContentCore.URLProvider` provider.
- Provide an implementation for `url`
- Provide an implementation for `headers` 
- Provide an implementation for `deliveryChannelToken` 
- Assign your class to `Onboarding.urlProvider`

#### Create a Class Conforming to URLProvider 
You should create your own class which conforms to OracleContentCore's `URLProvider` protocol. This protocol surfaces three variables, **url**, **headers** and **deliveryChannelToken**

#### The url variable

The url variable is used retrieve the base URL to which web services are submitted. The URL should contain only the scheme, host and port (if necessary). It should not return the full path necessary for a web service call as this will differ for each service.

```swift
var url: () -> URL? { get set }
```

#### The headers variable 
The headers variable allows you to provide your own key/value pair that will appear in the header of all library services. You may choose to use this, for example, to pass an Authorization header if you are accessing secure publishing channels. See [Channel Token and Authentication](https://docs.oracle.com/en/cloud/paas/content-cloud/rest-api-content-delivery/Channel_Token_and_Authentication.html) for information on how to obtain an OAuth token

```swift 
var headers: () -> [String: String] 
``` 

#### The channelToken variable 
The channelToken variable allows to provide a common value to be used by all Delivery library services. This is useful when all of your web service calls are targeting assets published to a single channel.

```swift 
var deliveryChannelToken: () -> String? 
``` 

All together, your implementation may look something like this: 

```swift 
class MyURLProvider: URLProvider { 
   // provide the base URL to use for each service call
   var url: () -> URL? = { 
      return URL(string: "https://foo.com")
   }

   // provide any additional headers you want submitted for each service call
   // This is purely optional for the Delivery API. No additional headers are REQUIRED for this library in most cases
   var headers: () -> [String: String] = { 
      [
         "key1": "value1",
         "key2": "value2"
      ]
   }

   // alternately, if you do not require any additional headers at all, you would define the headers variable like this:
   // var headers: () -> [String: String] = { return [] }


   // provide the default delivery channel token for each service call
   var deliveryChannelToken: () -> String? { "12345" }
}
```

#### Assign an instance of your class to Onboarding
You need to tell the library to use your `URLProvider` implementation. You do this by assigning to the `Onboarding.urlProvider` property.

```swift 
Onboading.urlProvider = MyURLProvider()
```

#### Create and submit your service 
```swift
let service = DeliveryAPI.listAssets()
let result = try await service.fetchNext() 
```
> Note: Note the simplicity of the call site when values are provided via your own `URLProtocol` implementation. This is very useful when you have many services and they all retrieve published objects from the same publishing channel. Why specify the same information over and over when you can simply specify it one time?









Your implementation may look something like this: 
```swift 
var deliveryChannelToken: () -> String? { "123456" }
```


