// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

///
/// Interfaces for the Delivery SDK relating to Downloads
///
// MARK: Download Native
extension DeliveryAPI {
    
    /**
     Download the native rendition for an asset
     
     Service is executable via conformance to `ImplementsDownload`
     
     Invocation verbs are:
     * download - returns an `OracleContentCore.DownloadResult` model object that supplies a  `URL`
     * download (with storage location) - returns an `OracleContentCore.DownloadResult` model object that supplies a  `URL`
           
     - parameter identifier: The identifier of the asset to download
     - returns: ``DownloadNative`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadNative(identifier: "123")
        .channelToken("12345")
     
     service.download { result in
        // handler code
     }
     ```
     */
    public class func downloadNative(identifier: String) -> DownloadNative {
        return DownloadNative(identifier: identifier)
    }
    
    /**
     Download the native rendition for an asset, utilizing an `ImageProvider` to handle cached images. This service should be used when your cache is image-based rather than URL-based.
     
     Invocation verb is:
     * downloadImage - returns an `OracleContentCore.DownloadResult` model object that supplies an `OracleContentCore.OracleContentImage`
           
     - parameter identifier: The identifier of the asset to download
     - parameter imageProvider: A caller-provided implementation conforming to the `ImageProvider` protocol
     - parameter cacheKey: The caller-provided key for the object to identify the asset in cache
     - returns: ``DownloadNative`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadNative(identifier: "123", imageProvider: MyImageProvider(), cacheKey: "CONT123ABC456")
        .channelToken("12345")
     
     service.download { result in
        // handler code
     }
     ```
     */
    public class func downloadNative(
        identifier: String,
        imageProvider: ImageProvider,
        cacheKey: String
    ) -> DownloadImageProviderNative {
        return DownloadImageProviderNative(identifier: identifier, imageProvider: imageProvider, cacheKey: cacheKey)
    }
    
    /**
     Download the native rendition for an asset, utilizing a `CacheProvider` to handle cached images. This service should be used when your cache is URL-based rather than image-based.
     
     Invocation verbs is:
     * download - returns an `OracleContentCore.DownloadResult` model object that supplies a  `URL`
           
     - parameter identifier: The identifier of the asset to download
     - parameter imageProvider: A caller-provided implementation conforming to the `ImageProvider` protocol
     - parameter cacheKey: The caller-provided key for the object to identify the asset in cache
     - returns: ``DownloadNative`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadNative(identifier: "123", cacheProvider: MyCacheProvider(), cacheKey: "CONT123ABC456")
        .channelToken("12345")
     
     service.download { result in
        // handler code
     }
     ```
     */
    public class func downloadNative(
        identifier: String,
        cacheProvider: CacheProvider,
        cacheKey: String
    ) -> DownloadCacheProviderNative {
        return DownloadCacheProviderNative(identifier: identifier, cacheProvider: cacheProvider, cacheKey: cacheKey)
    }
}

// MARK: Download Rendition
extension DeliveryAPI {
    
    /**
     Download a named rendition for an asset
     
     Service is executable via conformance to `ImplementsDownload`
     
     Invocation verbs are:
     * download - returns an `OracleContentCore.DownloadResult` model object that supplies a `URL`
     * download (with storage location) - returns an `OracleContentCore.DownloadResult` model object that supplies a `URL`
     
     - parameter identifier: The identifier of the asset to download
     - parameter renditionName: The name of the rendition to download
     - parameter format: Media type extension of the Digital Asset file. When the rendition has only one format, the format query parameter can be omitted
     - parameter type: Rendition type of the Digital Asset
     - returns: ``DownloadRendition`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadRendition(identifier: "123", renditionName: "USDZ")
        .channelToken("12345")
     
     service.download { result in
        // handler code
     }
     ```
     */
    public class func downloadRendition(
        identifier: String,
        renditionName: String,
        format: String? = nil,
        type: String? = nil
    ) -> DownloadRendition {
        return DownloadRendition(identifier: identifier,
                                 renditionName: renditionName,
                                 format: format,
                                 type: type)
    }
    
    /**
     Download a named rendition for an asset, utilizing an `ImageProvider` to handle cached images. This service should be used when your cache is image-based rather than URL-based.
     
     Invocation verbs is:
     * downloadImage - returns an `OracleContentCore.DownloadResult` model object that supplies an `OracleContentCore.OracleContentImage`
           
     - parameter identifier: The identifier of the asset to download
     - parameter imageProvider: A caller-provided implementation conforming to the `ImageProvider` protocol
     - parameter cacheKey: The caller-provided key for the object to identify the asset in cache
     - parameter format: Media type extension of the Digital Asset file. When the rendition has only one format, the format query parameter can be omitted
     - parameter type: Rendition type of the Digital Asset
     - returns: ``DownloadNative`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadRendition(identifier: "123", renditionName: "USDZ", imageProvider: MyImageProvider(), cacheKey: "CONT123ABC456")
        .channelToken("12345")
     
     service.downloadImage { result in
        // handler code
     }
     ```
     */
    public class func downloadRendition(
        identifier: String,
        renditionName: String,
        imageProvider: ImageProvider,
        cacheKey: String,
        format: String? = nil,
        type: String? = nil
    ) -> DownloadImageProviderRendition {
        return DownloadImageProviderRendition(identifier: identifier,
                                              renditionName: renditionName,
                                              imageProvider: imageProvider,
                                              cacheKey: cacheKey,
                                              format: format,
                                              type: type)
    }
    
    /**
     Download the native rendition for an asset, utilizing a `CacheProvider` to handle cached images. This service should be used when your cache is image-based rather than URL-based.
     
     Invocation verbs is:
     * download - returns an `OracleContentCore.DownloadResult` model object that supplies a  `URL`

     - parameter identifier: The identifier of the asset to download
     - parameter cacheProvider: A caller-provided implementation conforming to the `CacheProvider` protocol
     - parameter cacheKey: The caller-provided key for the object to identify the asset in cache
     - parameter format: Media type extension of the Digital Asset file. When the rendition has only one format, the format query parameter can be omitted
     - parameter type: Rendition type of the Digital Asset
     - returns: ``DownloadNative`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadRendition(identifier: "123", renditionName: "USDZ", imageProvider: MyImageProvider(), cacheKey: "CONT123ABC456")
        .channelToken("12345")
     
     service.download { result in
        // handler code
     }
     ```
     */
    public class func downloadRendition(
        identifier: String,
        renditionName: String,
        cacheProvider: CacheProvider,
        cacheKey: String,
        format: String? = nil,
        type: String? = nil
    ) -> DownloadCacheProviderRendition {
        return DownloadCacheProviderRendition(identifier: identifier,
                                              renditionName: renditionName,
                                              cacheProvider: cacheProvider,
                                              cacheKey: cacheKey,
                                              format: format,
                                              type: type)
    }
}

// MARK: Download Thumbnail
extension DeliveryAPI {

    /**
     Download the thumbnail rendition for an asset
     
     Service is executable via conformance to `ImplementsDownload`
     
     Invocation verbs are:
     * download - returns an `OracleContentCore.DownloadResult` model object that supplies  a `URL`
     * download (with storage location) - returns  an `OracleContentCore.DownloadResult` model object that supplies a `URL`
           
     - parameter identifier: The identifier of the asset to download
     - parameter fileGroup: The file group of the object.  Typically, this value is obtained from a prior call to `readAsset` and then extracting the `fileGroup` value. The fileGroup is used to differentiate thumbnails for digital assets, videos and "advanced videos".
     - parameter advancedVideoInfo: Typically obtained from a prior call to `readAsset`. Used to differentiate thumbnails for supported video types. The most-common scenario would be to request a thumbnail for a "videoPlus" file.
     - returns: ``DownloadThumbnail`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadThumbail(identifier: "123", fileGroup: "Videos", advancedVideoInfo: nil)
        .channelToken("12345")
     
     service.download { result in
        // handler code
     }
     ```
     */
    public class func downloadThumbnail(
        identifier: String,
        fileGroup: String,
        advancedVideoInfo: EmbeddedAdvancedVideoInfo? = nil
    ) -> DownloadThumbnail {
        return DownloadThumbnail(identifier: identifier, fileGroup: fileGroup, advancedVideoInfo: advancedVideoInfo)
    }
    
    /**
     Download the thumbnail rendition for an asset, utilizing an `ImageProvider` to handle cached images. This service should be used when your cache is image-based rather than URL-based.
     
     Invocation verbs is:
     * downloadImage - returns an `OracleContentCore.DownloadResult` model object that supplies an `OracleContentCore.OracleContentImage`
           
     - parameter identifier: The identifier of the asset to download
     - parameter fileGroup: The file group of the object.  Typically, this value is obtained from a prior call to `readAsset` and then extracting the `fileGroup` value. The fileGroup is used to differentiate thumbnails for digital assets, videos and "advanced videos".
     - parameter imageProvider: A caller-provided implementation conforming to the `ImageProvider` protocol
     - parameter cacheKey: The caller-provided key for the object to identify the asset in cache
     - parameter advancedVideoInfo: Typically obtained from a prior call to `readAsset`. Used to differentiate thumbnails for supported video types. The most-common scenario would be to request a thumbnail for a "videoPlus" file.
     - returns: ``DownloadThumbnail`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadThumbail(identifier: "123", fileGroup: "Videos", imageProvider: myImageProvider, cacheKey: "CONT123ABC", advancedVideoInfo: nil)
        .channelToken("12345")
     
     service.downloadImage { result in
        // handler code
     }
     ```
     */
    public class func downloadThumbnail(
        identifier: String,
        fileGroup: String,
        imageProvider: ImageProvider,
        cacheKey: String,
        advancedVideoInfo: EmbeddedAdvancedVideoInfo? = nil
    ) -> DownloadImageProviderThumbnail {
        return DownloadImageProviderThumbnail(identifier: identifier,
                                              imageProvider: imageProvider,
                                              cacheKey: cacheKey,
                                              fileGroup: fileGroup,
                                              advancedVideoInfo: advancedVideoInfo)
    }
    
    /**
     Download the thumbnail rendition for an asset, utilizing a `CacheProvider` to handle cached images. This service should be used when your cache is URL-based rather than cache-based.
     
     Invocation verbs is:
     * download - returns an `OracleContentCore.DownloadResult` model object that supplies a  `URL`
           
     - parameter identifier: The identifier of the asset to download
     - parameter fileGroup: The file group of the object.  Typically, this value is obtained from a prior call to `readAsset` and then extracting the `fileGroup` value. The fileGroup is used to differentiate thumbnails for digital assets, videos and "advanced videos".
     - parameter cacheProvider: A caller-provided implementation conforming to the `CacheProvider` protocol
     - parameter cacheKey: The caller-provided key for the object to identify the asset in cache
     - parameter advancedVideoInfo: Typically obtained from a prior call to `readAsset`. Used to differentiate thumbnails for supported video types. The most-common scenario would be to request a thumbnail for a "videoPlus" file.
     - returns: ``DownloadThumbnail`` service
     
     Swift Usage Example:
     ```swift
     let service = DeliveryAPI
        .downloadThumbail(identifier: "123", fileGroup: "Videos", cacheProvider: myCacheProvider, cacheKey: "CONT123ABC", advancedVideoInfo: nil)
        .channelToken("12345")
     
     service.download { result in
        // handler code
     }
     ```
     */
    public class func downloadThumbnail(
        identifier: String,
        fileGroup: String,
        cacheProvider: CacheProvider,
        cacheKey: String,
        advancedVideoInfo: EmbeddedAdvancedVideoInfo? = nil
    ) -> DownloadCacheProviderThumbnail {
        return DownloadCacheProviderThumbnail(identifier: identifier,
                                              cacheProvider: cacheProvider,
                                              cacheKey: cacheKey,
                                              fileGroup: fileGroup,
                                              advancedVideoInfo: advancedVideoInfo)
    }
}
