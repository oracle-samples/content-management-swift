# Decoding Objects

Find out how to decode and encode Delivery library objects.

## Overview
All of the model objects provided by the Delivery library conform to the `Codable` protocol. They may be easily transformed from `Data` values into model objects and vice versa. While most of this transformation is fairly straightforward (and transparent to calling code), "dates" present a particular problem.

This problem will become very apparent if you choose to use other transport methodologies (like Alamofire or URLSession.dataTaskPublisher) to submit web service calls. It may also be very important for your testing code.

## Date Fields 
Date fields are returned as JSON objects by the server while data model's store "date" values as true `Date` objects. 

Example of a date field returned by the server 
```swift 
"createdDate": {
   "value": "2020-04-07T18:54:57.951Z",
   "timezone": "UTC"
}
```

Data model objects reference this as a simple `Date` object. For example, 

```swift
class Asset: Codable { 
   var createdDate: Date
}
``` 

## LibraryJSONDecoder 
You need a `JSONDecoder` with a `defaultDateDecodingStrategy`. Rather than having to go through manual steps each time you want to decode an object, the Delivery library provides the LibraryJSONDecoder class - a preconfigured instance of `JSONDecoder` with the date strategy already provided.

Turning data into an ``Asset`` object is easy.

```swift 
   let asset = try LibraryJSONDecoder().decode(Asset.self, from: data)
```

> Important: You cannot use a plain `JSONDecoder`. The following code will throw an error:
> ```swift 
>    let asset = try JSONDecoder().decode(Asset.self, from: data)
> ```

## Transforming a Service Response 
The Delivery library also exposes a method which can be used when you are submitting service calls using your own transport mechanism (like URLSession.dataTaskPublisher or Alamofire). 

That helper function is: 
``DeliveryAPI/decode(type:from:response:)``

One implementation in a pipeline might be to do this: 
```swift 
.tryCompactMap {
    // decode into an Assets model object or throw an OracleContentError
    try DeliveryAPI.decode(type: Assets.self, from: $0.data, response: $0.response)
}
```

See <doc:UsingOtherTransports> for additional information on this use case



