# Configuring A CacheProvider

Implement your own version of an `OracleContentCore.CacheProvider`` when you want to download operations to interface with your URL-based cache.

## Overview

When performing download operations, you can automatically interface with your existing cache implementation by creating an object that conforms to the `CacheProvider` protocol.

### Service Instantiation ###

You must instantiate your download service using one of the initializers that supports an `OracleContentCore.CacheProvider`. 

For example, the ``DeliveryAPI/downloadNative(identifier:cacheProvider:cacheKey:)`` service will allow for downloading the native rendition of an asset and will utilize your existing URL-based cache.

```swift 
    let service = DeliveryAPI.downloadNative(identifier: "123", 
                                             cacheProvider: myCacheProvider,
                                             cacheKey: "123")
```

### The CacheProvider Parameter ### 

Create your own object that conforms to the `OracleContentCore.CacheProvider` protocol

```swift 
struct MyCacheProvider: CacheProvider { 
    // implement required methods/properties
}
```

### CacheProvider Required Methods/Properties ###

#### cachePolicy Property ####

The cachePolicy is used to specify whether download services should always make a server call or should bypass server calls if the requested object is found in cache. 

In most cases, you want your cachePolicy implementation to return `.bypassServerCallOnFoundItem`. 

However, there are times when you may want to actually attempt a server call. If that is the case, you want to return `.alwaysFetchWithCustomHeader`.  An example of this may be when your cache is based on ETag values. In this case, you want the download service to actually fetch from the server and then you want to react to the case where an ETag is returned. 

```swift
/// Determines whether to ask the cache for an item 
/// matching the key before attempting any web service call.
var cachePolicy: CachePolicy { get }
```

#### find Method ####
This method is called from the download implementation. Its primary purpose is to determine whether or not to make a call to the server. Provide your own method to return a URL if an entry is found in cache matching the specified key. 

- note This method is only called when the cachePolicy is set to bypassServerCallOnFoundItem

```swift
func find(key: String) -> URL? { 
    // look in your cache for a URL that matches the specified key value
    // If found, return the URL
    // Otherwise, return nil 
}
```

#### cachedItem Method ####
This method called from the download implementation. It is used when a web service call has been made and the server returned a 304 Not Modified response. In this case, the cache has the opportunity to either provide its cached value for the key or throw an error.

Returns a URL representing the file URL of the item matching the key. If none exists, throw an error so that the entire pipeline can fail. Otherwise return a URL so that the pipeline can return success

Throws `Error` if the CacheProvider is unable to provide a URL matching the specified key

```swift 
func cachedItem(key: String) throws -> URL { 
   /// look in the cache for the asset matching the specified key
   /// If found, return its URL
   /// If not found, throw an Error
}
```

#### store Method ####
This method is called from the download implementation. Its purpose is to store the asset (located at the specified URL) in your cache.

It provides the current file URL, the key you'd previously specified for this asset, as well as the headers returned by the server call (which you may inspect as required)

On error, you should throw an `Error` in order to force the pipeline to fail

```swift 
func store(objectAt file: URL, key: String, headers: [AnyHashable: Any]) throws { 
    // Copy the file URL into your cache
    // Throw an error if the storage fails 
}
```

#### headerValues Method ####
Provide additional headers to use for the service call. This is useful, for example, when implementing a cache that utilizes Etag values and you want the current Etag value to appear in the header of the download service call.

```swift 
func headerValues(for cacheKey: String) -> [String: String] { 
    // provide your own header values
}
```

### Invocation Verb ###
You must only use one of the following invocation verbs:

```swift 
func download(progress: ((Double) -> Void)?,
              completion: @escaping (Result<DownloadResult<URL>, Error>) -> Void)

func download(progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error>

func downloadAsync(progress: ((Double) -> Void)?) async throws -> DownloadResult<URL>
```

Other invocation verbs referencing either a storage location or titled "downloadImage" will not honor the existence of a CacheProvider 

See Example code for an implementation of download utilizing a CacheProvider
