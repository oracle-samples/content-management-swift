# DownloadingAssets

Downloading assets may be accomplished using several different techniques. This article will walk you through the download process and show how to optionally integrate with your existing cache.

## Overview

Downloading an asset involves several different services and three different invocation verbs. The "right" method to choose depends on what you want to download and whether or not you wish to integrate with an existing cache implementation.

### Service Types ###
The base download service interfaces consist of three groups:

* **Native Downloads** - provide access to the native/original asset object
* **Rendition Downloads** - provides access to a particular rendition of the specified format and type 
* **Thumbnail Downloads** - provides access to the specific rendition that is defined as a thumbnail

### Service Varieties ###
Each type of service interface comes in three different varieties:

* **Simple** - bypasses user-defined caches
* **Cache Provider** - utilizes a user-defined cache that stores cached objects as URLs
* **Image Provider** - utilizes a user-defined cache that stores cached objects as `OracleContentCore.OracleContentImage`

### Invocation Verbs ### 
Each type of service interface provides for three different invocation verbs: 

* **download** - returns an `OracleContentCore.DownloadResult` model object that supplies a  `URL`
* **download (with storage location)** - returns an `OracleContentCore.DownloadResult` model object that supplies a  `URL`
* **downloadImage** - returns an `OracleContentCore.DownloadResult` model object that supplies an `OracleContentCore.OracleContentImage`
      
## Simple Example ##
Let's look at simple download of a native asset object that does not utilize any cache providers.

- note: This example assumes that the `Onboarding` process has been followed. See <doc:ConfiguringTheURLProvider> for more information.

```swift 

import OracleContentCore
import OracleContentDelivery
import Combine 

var cancellables = [AnyCancellable]() 

let c: AnyCancellable?

c = DeliveryAPI
    .downloadNative(identifier: "12345")
    .download(progress: nil)
    .receive(on: RunLoop.main)
    .sink(receiveCompletion: { completion in
        switch completion { 
        case .failure(let error):
            // handle the error 
            print(error.localizedDescription)

            if let serverStatusCode = (error as? OracleContentError)?.serverStatusCode {
               print("Server Status Code: \(serverStatusCode)")
            }

            if let jsonResponse = (error as? OracleContentError)?.jsonValue {
               print("JSONValue: \(jsonResponse)")
               print("JSONString: \(jsonResponse.jsonString())")
            }

        default:
            // break 
        }
        if c != nil  {
            self.cancellables.removeAll { $0 === c }
            c = nil
        }
    }, receiveValue: { downloadResult in
        myImageURL = downloadResult.result
    })

    c?.store(in: &cancellables)

```

- You need to import both `OracleContentCore` and `OracleContentDelivery`. For `Future`-based invocation verbs, you also need to import `Combine`

- The service interface being used is ``DeliveryAPI/downloadNative(identifier:)``

- The invocation verb being used is:
```swift 
// Note that the invocation verb provides for a progress callback 
// which updates with a completion percentage as the download continues
func download(progress: ((Double) -> Void)?) -> Future<DownloadResult<URL>, Error>
```

- When the service completes, we force processing back to the main thread. This is necessary in cases where you are updating `State` or UI (which must occur on the main thread).

- In the "happy path" where we encounter no errors, we enter the "receiveValue" closure in `sink`. The result object is of type `DownloadResult<URL>` - meaning that our result is URL-based.  We can access the `.result` property (of type URL) and assign it to an object of our choosing. The "receiveCompletion" will then execute and our memory usage will be cleaned up.

- If an error is encountered, control flow will immediately jump into the the "receiveCompletion" closure in `sink`. Here we can capture the `.failure` case and inspect the resulting error.

```

See the included example code for additional download implementations 

** Native Downloads**
- ``DeliveryAPI/downloadNative(identifier:)``
- ``DeliveryAPI/downloadNative(identifier:cacheProvider:cacheKey:)``
- ``DeliveryAPI/downloadNative(identifier:imageProvider:cacheKey:)``

These download interfaces will access 

** Rendition Downloads** 
- ``DeliveryAPI/downloadRendition(identifier:renditionName:format:type:)``
- ``DeliveryAPI/downloadRendition(identifier:renditionName:cacheProvider:cacheKey:format:type:)``
- ``DeliveryAPI/downloadRendition(identifier:renditionName:imageProvider:cacheKey:format:type:)``

** Thumbnail Downloads**
- ``DeliveryAPI/downloadThumbnail(identifier:fileGroup:advancedVideoInfo:)``
- ``DeliveryAPI/downloadThumbnail(identifier:fileGroup:cacheProvider:cacheKey:advancedVideoInfo:)``
- ``DeliveryAPI/downloadThumbnail(identifier:fileGroup:imageProvider:cacheKey:advancedVideoInfo:)``




## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
