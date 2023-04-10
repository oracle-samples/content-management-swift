#  Simple Asset Listing Example

The examples contained in this project show how to perform list, read and download actions in several different contexts.
In each case, the "list" request issued is limited to 50 items at a time and the query performed asks only for "Images" with a file extension of "jpg".

To run this code, open the SimpleAssetListingExample.xcodeproj contained in the Examples/SimpleAssetListing/SimpleAssetingListingExample directory.

** Important **
You need to modify the class `MyURLProvider` contained in `SimpleAssetListingExampleApp`. You should provide the URL to your OCM instance, as well as a channel token containing published image assets.

The `Future` example shows how to make service calls using the `Future` form of the invocation verb `list`, `read` and `download`. No caching is performed

The `Async` example shows to make service using the `Async/Await` form of the invocation verb 'list', `read` and `download`. No caching is performed.

The `CacheProvider` example is similar to the `Async` example, however the important part of the code lies in the Asset view once you've drilled into a result. This shows how you could implement a persisted, URL-based cache that utilizes Etag header values and interface with library functionality through the use of an OracleContentCore.CacheProvider

The `ImageProvider` example is also similar to the `Async` example. Again the important part lies in the Asset view once you've drilled into a result. This shows how you could have a temporary in-memory cache that stores UIImage values and interface with library functionality through the use of an OracleContentCore.ImageProvider. Additionally, it's worth noting that the ImageProvider example shows how to utilize a QueryBuilder as part of the service definition, rather than the raw text query utilized by other examples

The `Clear Cache` button just provides a way to clear out any cached files/images that were stored while examining the samples.

