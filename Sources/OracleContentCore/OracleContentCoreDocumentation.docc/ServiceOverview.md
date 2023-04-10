# Service Overview 
Learn about the structure, naming conventions and supported functionality of the library services.

## Base Classes
OracleContentCore provides two base services from which most common library services derive: ``BaseService`` and ``BaseDownloadService``. 

#### BaseService

`BaseService` is generic over `Element` which must be a `Decodable` object. 

Most of the Oracle-provided services will automatically decode JSON responses from the server into a structured data model object. When the Oracle libraries define a service, they specifically identify the `Decodable` model object which will be used by the base implementations.

The net result is that in most cases callers do not need to perform additional decoding of raw data. 

#### BaseDownloadService 

`BaseDownloadService` is NOT generic over a `Decodable` object. Results are delivered via a file URL rather than as a structured data model item.

## LibraryFetchable  
Both base services conform to the ``LibraryFetchable`` protocol which means that each will surface:

- the ability to cancel the service 
- a unique service identifier string value 
- the URL for the service
- the URLRequest for the service 

## Service Parameters 
The base classes each define a property of type ``ServiceParameters``. Each concrete service in the Oracle libraries populates this value with an object which derives from ``ServiceParameters``  

**Key elements provided by ServiceParameters**  

- term ``ServiceParameters/serviceSuffix``:
Builds the trailing part of the path necessary for a particular service. An example **serviceSuffix** from a service to read an Asset, may result in String that looks like:
````
"/items/CORE39692EADB05D4441BA6BBD25BFD81E02"
````

- term ``ServiceParameters/isWellFormed()``: 
Returns true if the service parameters have been sufficiently provided in order to build the URL and URLRequest. 

- term ``ServiceParameters/buildURL()``: 
Retrieves the various URL parts and composes them into a *full* URL suitable for submission.

- term ``ServiceParameters/request()``: 
Builds the URLRequest according to the requirements of the service. This includes populating the type of request (GET, POST, etc) and any necessary request body data.

> Note: Service parameters are discussed in more detail in specific Oracle library documentation, such as the Delivery library.

## Namespacing 
Concrete services are namespaced according to the library in which they reside.

Each Oracle library will have an **`Interfaces`** folder which will define the available web services.

For example, the Delivery library contains the files:
- **`DeliveryAPI+Assets`**
- **`DeliveryAPI+Taxonomies`**
- **`DeliveryAPI+Download`**. 

Every service available in the Delivery library is defined in one of those files.

## Service Names 
Services in the Oracle libraries are typically named according to a standard. The first part of the service describes *what* you want to do and the second part of the name describes the object type that will be decoded from the response.

#### Service Names Common to all Oracle Libraries
- term **"read"** services: Used to fetch detailed information about a single item. Example: readAsset (note the singular object type)
- term **"list"** services: Used to fetch a collection of `Decodable` objects. Example: listTaxonomies (note the plural object type)
- term **"download"** services: Used to retrieve a binary object from the server 

## Composition 
Much of the functionality implemented in the Oracle libraries is accomplished through "composition" - the incremental combination of functionality that results in the construction of a single object. 

This functionality is provided through conformance to one or more of the `Implements<functionality>` protocols. Each protocol has a corresponding protocol extension where implementation details are provided. This means that a service will automatically support a compositional element simply by adopting the protocol - no additional code is required.

Compositional protocols provide three different types of functionality. 

**Common Invocation Verbs** are used to invoke the service.

- ``ImplementsBaseDownload``
- ``ImplementsCacheProviderDownload``
- ``ImplementsImageProviderDownload``
- ``ImplementsFetchDetail``
- ``ImplementsFetchListing``

**Common Builder Components** provide functionality to configure a service's support for optional parameters.
- ``ImplementsChannelToken``
- ``ImplementsExpand``
- ``ImplementsFields``
- ``ImplementsIsPublishedChannel``
- ``ImplementsLinks``
- ``ImplementsSortOrder``
- ``ImplementsTotalResults``
- ``ImplementsVersion``

**Common Per-Service Overrides** utilize different configuration data than was defined as part of the Onboarding process
- ``ImplementsDownloadOverrides``
- ``ImplementsOverrides``


## Invocation Verbs 
Web services are invoked through the use of special "verb" functions. The specific "verb" functions available are dependent upon the compositional elements adopted by the service.

Some common "verbs" are: 

#### fetch
fetch is used to retrieve details about a single object. It is available via conformance to ``ImplementsFetchDetail``

#### fetchNext 
fetchNext is used to retrieve listing information about a collection of decodable objects. It is available via conformance to ``ImplementsFetchListing``

> Tip: When utilizing the `fetchNext` verb, there is no need to manually keep track of the offsets. You can keep calling fetchNext until no more data is available. You will know that no more data is available in two different ways: 
>
>- the service's ``ServiceParameters/hasMore`` property will be false 
>- the service will error with ``OracleContentError/noMoreData``

#### download 
download is used to download a binary object such as a digital asset, thumbnail or rendition. It is available via conformance to either ``ImplementsBaseDownload`` or ``ImplementsCacheProviderDownload``

#### downloadImage 
downloadImage is used to download a digital asset image when interfacing with a caller-provided `OracleContentCore.ImageProvider`. It is available via conformance to ``ImplementsImageProviderDownload``

## Builder Components 
The Oracle library services were designed in a way that can easily accomodate future functionality through the usage of `builder components`. `Builder components` are small functions called as part of a service definition which modify the underlying `ServiceParameters`. This eliminates the need for lengthy, fixed-order parameter signatures. Instead, uptaking developers can choose which `builder component` methods to call...and they can be called in any order.

For example, the Delivery service to "read" an asset has the following signature. Note that the assetId is a required parameter as part of the service definition itself. It must be supplied so that the service knows which asset to retrieve.

```swift 
public class func readAsset(assetId: String) -> ReadAsset<Asset> 
```

The Delivery library `ReadAsset` service conforms to several compositional protocols which allows for code such as this:

```swift 
let service = DeliveryAPI.readAsset(assetId: "123")
                         .channelToken("22222222")
                         .expand(.all)
```

More information about each service is available in the library documenation.

Additionally, more examples are available in the unit tests.

## Per-Service Overrides 
The onboarding documentation describes how uptaking code can define common values for the base URL, headers and URLSessions used as part of each web service call. 

However, services that conform to ``ImplementsOverrides`` or ``ImplementsDownloadOverrides`` have the ability to inject different data for a single invocation. 

To override the URL and headers used for a single service call, use the following method
```swift 
func overrideURL(_ url: URL, headers: ProvidesURLRequestHeaders? = nil) 
```

To override the URLSession, provide a URLSessionConfiguration object from which a new URLSession will be constructed

```swift
func overrideSessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) 
```

The per-service override methods function just like the other builder components. 

## Control Flow
Services may be invoked using different control flow mechanisms. (Most services offer callback, Future and async/await implementations.) Uptaking code may choose to utilize any of the available control flows for any services submitted.

We can look at some examples using the Delivery library's implementation of the **listAssets()** service, which conforms to ``ImplementsFetchListing`` and therefore exposes three separate **invocation verbs**

#### Callback flow 

One variant of the **fetchNext** invocation verb defines a `Swift.Result<Element, Error>` callback type. It may be invoked as follows: 

```swift 
let service = DeliveryAPI.listAssets()
service.fetchNext { result in 
    switch result { 
       case .success(let listing): 
          // handle values 

       case .failure(let error): 
          // handle error 
    }
}
```

#### Future flow

One variant of the **fetchNext** invocation verb defines a `Future<Element, Error>` return type. It may be invoked as follows:

```swift 
let service = DeliveryAPI.listAssets() 
let cancellable = service.fetchNext()
                    .map { /* handler */ }
                    .sink { /* handler */ }
```

### Async/Await flow 

A final variant of the **fetchNext** invocation verb defines an `aysnc/await` usage pattern. It may be invoked as follows:

```swift 
let result = try await DeliveryAPI.listAssets().fetchNextAsync() 
// handle success case - errors are thrown
```

## Closing Notes 
Additional (and more specific) documentation about service calls is available in other Oracle library documentation. Also, many of the topics discussed here are examined and validated in the provided unit tests. 
