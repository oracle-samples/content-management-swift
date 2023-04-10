# ``OracleContentDelivery``

The REST API for Content Delivery enables you to access published content stored in Oracle Content Mangement Cloud. This library provides a Swift language implementation of the REST API.

## Overview

The Delivery library allows uptaking code to access published data from specified channels without manually building complex URLs. Results are returned in structured data model objects allowing for simple inspection and display of values.

## Getting Started
You can make your first web service call without any additional service configuration. You need only two things: 1) the Content Management URL, and 2) the channel token to which your asset was published.

#### Required Imports 
Always import both the OracleContentCore and OracleContentDelivery libraries
```swift
import OracleContentCore 
import OracleContentDelivery
```

#### Define a URL 
You need to tell the library the base Content Management URL to which services should be submitted. 

```swift 
let url = URL(string: "https://foo.com")!
```

#### Create the service
All Delivery services are namespaced to ``DeliveryAPI``.  

Delivery service names are of the form:  `[list|read|download][model type]`
In this case, if you want to **list** the published **Assets**, the service you would use is `DeliveryAPI.listAssets()`.

The `listAssets` service does not have any required parameters, but additional information **IS** required in this quick-start scenario. Here we use the `overrideURL` and `channelToken` **builder components** to provide necessary information for the service.

> Note: See <doc:FindTheChannelToken> for information on how to find the channel token to specify

```swift
let service = DeliveryAPI.listAssets()
                         .overrideURL(url, headers: [])  
                         .channelToken("12345") 
```

#### Submitting the service 
You submit the service by using the appropriate **invocation verb**. 
|**Service type**|**Invocation Verb**|
| ----------------------------- | ----------------------------- |
| list | fetchNext |
| read | fetch |
| download | download |

Here we use the closure form of `fetchNext`
```swift
service.fetchNext { result in 
   switch result { 
   case .success(let listing): 
      // handle values 

   case .failure(let error): 
      // handle error 
   }
}
```

You could also use the Future form:
```swift 
let cancellable = service.fetchNext()
                         .sink { }
```

or the async form:
```swift 
let result = try await service.fetchNextAsync()
```

## Onboarding 
The previous quick-start example, while useful, becomes a little too verbose when you are making multiple service calls throughout your application. When you follow the Onboarding process, you can specify the URL and channel token one time and have all web services utilize this same information without having to manually repeat it over and over. Additionally, the Onboarding process allows for user-provided logging implementations and custom URLSessions.

The onboarding process consists of three protocols whose concrete implementations are surfaced through the `OracleContentCore/Onboarding` enum.
* `OracleContentCore/URLProvider` - defines the base URL for your Oracle Content Management server, header values which should be used for the request and the common channel token (Delivery library only) from which assets are fetched. See <doc:ConfiguringTheURLProvider> for more information

* `OracleContentCore/LoggingProvider` - defines an interface which may be implemented to support logging of library activies. See <doc:ConfiguringTheLoggingProvider> for more information.

* `OracleContentCore/SessionProvider` - defines an interface allowing for fine-grained control of the URLSession used when executing web service calls. See <doc:ConfiguringTheSessionProvider> for more information.

## Topics

### Getting Started 
- <doc:FindTheChannelToken>
- <doc:UsingOtherTransports>
- <doc:ConfiguringTheURLProvider>
- <doc:ConfiguringTheLoggingProvider>
- <doc:ConfiguringTheSessionProvider>
- <doc:DecodingObjects>

### Namespacing
All services are namespaced to `DeliveryAPI` and are available via code completion
- ``DeliveryAPI``

### Retrieving Assets
- ``DeliveryAPI/listAssets()``
- ``DeliveryAPI/readAsset(assetId:)``
- ``DeliveryAPI/readAsset(slug:)``

### Asset service classes:
- ``ListAssets``
- ``ReadAsset``

### Retrieving Taxonomies
Taxonomy services are defined in `DeliveryAPI+Taxonomies`. They include:
- ``DeliveryAPI/listTaxonomies()``
- ``DeliveryAPI/readTaxonomy(taxonomyId:)``
- ``DeliveryAPI/listTaxonomyCategories(taxonomyId:)``
- ``DeliveryAPI/readTaxonomyCategory(taxonomyId:categoryId:)``

### Taxonomy service classes
- ``ListTaxonomies``
- ``ListTaxonomyCategories``
- ``ReadTaxonomy``
- ``ReadTaxonomyCategory``

### Performing Downloads
Download services are defined in `DeliveryAPI+Downloads`. They include:
- <doc:DownloadingAssets>
- <doc:ConfiguringACacheProvider>
- ``DeliveryAPI/downloadNative(identifier:)``
- ``DeliveryAPI/downloadNative(identifier:cacheProvider:cacheKey:)``
- ``DeliveryAPI/downloadNative(identifier:imageProvider:cacheKey:)``
- ``DeliveryAPI/downloadThumbnail(identifier:fileGroup:advancedVideoInfo:)``
- ``DeliveryAPI/downloadThumbnail(identifier:fileGroup:cacheProvider:cacheKey:advancedVideoInfo:)``
- ``DeliveryAPI/downloadThumbnail(identifier:fileGroup:imageProvider:cacheKey:advancedVideoInfo:)``
- ``DeliveryAPI/downloadRendition(identifier:renditionName:format:type:)``
- ``DeliveryAPI/downloadRendition(identifier:renditionName:cacheProvider:cacheKey:format:type:)``
- ``DeliveryAPI/downloadRendition(identifier:renditionName:imageProvider:cacheKey:format:type:)``


### Download service classes
- ``DownloadNative``
- ``DownloadRendition``
- ``DownloadThumbnail``

### Data Model 
- ``Asset``
- ``Assets``
- ``Taxonomy``
- ``Taxonomies``
- ``TaxonomyCategory``


