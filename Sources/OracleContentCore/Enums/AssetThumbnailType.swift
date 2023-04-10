// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Used as part of the definition of the associated value for an AssetThumbnailType
public typealias AssetIdentifier = String

/// Enumeration detailing the types of asset download URLs that may be used
public enum AssetThumbnailType: ConvertibleToDownloadURL, Equatable {

    /// this is the normal thumbnail type for a digital asset
    case thumbnail(AssetIdentifier)
    
    /// videoPlusThumbnails have a different URL and ultimately return a video thumbnail from an external service
    case videoPlusThumbnail(AssetIdentifier)
    
    /// videoPlusStrips have a different URL and ultimately return a series of images from an external service that
    /// a caller can cycle through
    case videoPlusStrip(AssetIdentifier)
    
    /// static method to create the default thumbnail for a given identifier and fileGroup
    /// - parameter identifier: The identifier of the asset
    /// - parameter fileGroup: The  (optional) fileGroup for an asset which determines whether the object returned will be a thumbnailor a videoPlusThumbnail
    /// - returns: AssetThumbnailType
    public static func defaultThumbnail(for identifier: String,
                                        fileGroup: String?,
                                        advancedVideoInfo: EmbeddedAdvancedVideoInfo?) -> AssetThumbnailType {
        
        let fileGroupType = FileGroup(value: fileGroup,
                                      advancedVideo: advancedVideoInfo)
        
        switch fileGroupType {
        case .advancedVideos:
            return .videoPlusThumbnail(identifier)
            
        default:
            return .thumbnail(identifier)
        }
    }
    
    /// This method is the primary purpose of this enum.  It provides a completely encapsulated manner of determing the complete URL necessary to
    /// download a thumbnail
    /// - parameter version: The ManagementAPIVersion that should exist as part of the URL. Passing nil causes the "current" API version to be used.
    /// - returns: URL?
    public func urlForDownload(version: APIVersion? = nil, overrideURL: URL? = nil, basePath: String? = nil) -> URL? {

        let baseURL = overrideURL ?? Onboarding.urlProvider?.url()
        let basePath = basePath ?? LibraryPathConstants.baseDeliveryPath
        let version = version ?? LibraryPathConstants.currentAPIVersion
        
        let fullURL = baseURL?.appendingPathComponent(basePath)
                              .appendingPathComponent(version.rawValue)
                              .appendingPathComponent("assets")
                              .appendingPathComponent(self.assetIdentifier)
                              .appendingPathComponent(self.endpoint)
        
        guard let foundURL = fullURL,
              let baseComponents = URLComponents(url: foundURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        var mutableComponents = baseComponents
        mutableComponents.queryItems = self.queryItems
       
        return mutableComponents.url
    }
}

// MARK: Private values
/// The computed properties in this section represent helpers that assist with building the URL.
/// Note that these query parameters are truly provider agnostic
/// They make up a URL submitted to the Caas server. In the case of VideoPlus thumbnails (thumbnail and/or strip),
/// it's the job of the CaasServer to talk to Kaltura (or other) video providers and retrieve the thumbnail
/// It it therefore not necessary (at this time) to pass any information about a paritcular video provider.
///
extension AssetThumbnailType {
   
    private var queryItems: [URLQueryItem] {
        
        switch self {
        case .thumbnail:
            ///Bypass format as a workaround to enable WebP thumbnail generation from server
            ///due to absence of WebP  transcoding support to a given type.
            return [URLQueryItem(name: "type", value: "uithumbnail")]
            
        case .videoPlusStrip:
                return [URLQueryItem(name: "format", value: "jpg"),
                        URLQueryItem(name: "type", value: "advancedvideo")]
            
        case .videoPlusThumbnail:
                 return [URLQueryItem(name: "format", value: "jpg"),
                         URLQueryItem(name: "type", value: "advancedvideo")]
        }
    }
    
    private var assetIdentifier: String {
        switch self {
        case .thumbnail(let identifier),
             .videoPlusThumbnail(let identifier),
             .videoPlusStrip(let identifier):
                   return identifier
        }
    }
    
    private var endpoint: String {
        switch self {
        case .thumbnail:
            return "thumbnail"
            
        case .videoPlusThumbnail:
                return "Thumbnail"
            
        case .videoPlusStrip:
                return "Strip"
        }
    }
}

