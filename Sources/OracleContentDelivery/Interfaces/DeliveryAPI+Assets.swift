// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

///
/// Interfaces for the Delivery SDK relating to Assets
///
extension DeliveryAPI {
    /**
    Retrieve a listing of published assets in the specified channel
     
    The data model object returned is of type ``Assets``
     
    Service is executable using the `fetchNext` invocation verb defined via conformance to `ImplementsFetchListing`
     
    - returns: ``ListAssets`` service
    
    Swift Usage Example:
    ```swift
    let service = DeliveryAPI.listAssets().channelToken("12345")
    
    service.fetchNext { result in
    // handler code
    }
    ```
    */
    public class func listAssets() -> ListAssets<Assets> {
        return ListAssets()
    }
    
    /**
    Retrieve information about a published asset matching the specified slug value
    
    The data model object returned is of type ``Asset``
     
    Service is executable using the 'fetch' invocation verb defined via conformance to `ImplementsFetch`
     
    - parameter slug: The slug value of the asset
    - returns: ``ReadAsset`` service
    
    Swift Usage Example:
    ```swift
    let service = DeliveryAPI.readAsset(slug: "12345").channelToken("67890")
    
    service.fetch { result in
    // handler code
    }
    ```
    */
    public class func readAsset(slug: String) -> ReadAsset<Asset> {
        return ReadAsset(slug: slug)
    }
    
    /**
    Retrieve information about a published asset matching the specified assetId value
     
    The data model object is of type ``Asset``
     
    Service is executable using the 'fetch' invocation verb defined via conformance to `ImplementsFetch`
     
    - parameter assetId: The identifier of the asset
    - returns: ``ReadAsset`` service
    
    Swift Usage Example:
    ```swift
    let service = DeliveryAPI.readAsset(assetId: "12345").channelToken("67890")
    
    service.fetch { result in
     // handler code
    }
    ```
    */
    public class func readAsset(assetId: String) -> ReadAsset<Asset> {
        return ReadAsset(assetId: assetId)
    }
}
