// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// swiftlint:disable array_init

import Foundation
import OracleContentCore

/// Enumeration that defines the type of the override to be performed
public enum SupportedURLOverrides: String, CaseIterable, OverrideProtocol {
    case unknown
    
    case configurationSettings
    
    case repository
    case repositories
    case createRepository
    case editRepository
    case deleteRepository
    case repositoryPermissions
    
    case channel
    case channels
    case createChannel
    case editChannel
    case deleteChannel
    case channelPermissions
    
    case collection
    case collections
    case createCollection
    case editCollection
    case deleteCollection
    case collectionPermissions
    
    case bulkItemsOperations
    
    case items
    case item
    case createItem
    case editItem
    case deleteItem
    
    //    case ids
    case dataTypes
    
    case type
    case types
    case createType
    case editType
    case deleteType
    
    case providerTokens
    
    case assetBySlug
    
    case taxonomies
    case taxonomy
    case createTaxonomy
    case editTaxonomy
    case deleteTaxonomy
    
    case taxonomyCategories
    case taxonomyCategory

    case downloadNative
    case downloadThumbnailOrRendition
    
    case workflowAction
    case workflowTasks
    case workflowJobStatus
    
    case readLockInfo
    case readLockInfoBySlug
    case editLockInfo
    case editLockInfoBySlug
}

extension SupportedURLOverrides {
    
    /// Return the HTTPMethod and URL Path associated with an enumeration value
    public func requestPath() -> RequestPathStruct {
        switch self {
            
        case .unknown:
            return RequestPathStruct("")
            
        // Configuration Settings (system level)
        case .configurationSettings:
            return RequestPathStruct("configurations/settings")
                        
        // Items
        case .item, .items, .createItem, .editItem, .deleteItem:
            return self.itemsRequestPath()
            
        // Channels
        case .channel, .channels, .createChannel, .editChannel, .deleteChannel, .channelPermissions:
            return self.channelsRequestPath()
          
        // Respositories
        case .repository, .repositories, .createRepository, .editRepository, .deleteRepository, .repositoryPermissions:
            return self.repositoriesRequestPath()
            
        // Collections
        case .collection, .collections, .createCollection, .editCollection, .deleteCollection, .collectionPermissions:
            return self.collectionsRequestPath()
            
        // Types
        case .type, .types, .createType, .editType, .deleteType:
            return self.typesRequestPath()
           
        // Taxonomies
        case .taxonomy, .taxonomies, .createTaxonomy, .editTaxonomy, .deleteTaxonomy, .taxonomyCategories, .taxonomyCategory:
            return self.taxonomiesRequestPath()
            
        // Slugs
        case .assetBySlug:
            return self.bySlugRequestPath()
            
        case .bulkItemsOperations:
            return RequestPathStruct(.post, "bulkItemsOperations")
            
        case .dataTypes:
            return RequestPathStruct("dataTypes")
            
        case .providerTokens:
            return RequestPathStruct(.post, "items/{id}/versions/{version}/providerTokens")
            
        case .downloadNative:
            return RequestPathStruct("assets/{id}/native")
            
        case .downloadThumbnailOrRendition:
            return RequestPathStruct("assets/{id}/{rendition}")
            
        case .workflowAction:
            return RequestPathStruct(.post, "items/{assetId}/workflows/{workflowId}/activities/{activitiesId}")
            
        case .workflowTasks:
            return RequestPathStruct("workflowTasks")
            
        case .workflowJobStatus:
            return RequestPathStruct("bulkItemsOperations/{jobId}")
            
        case .readLockInfo, .readLockInfoBySlug, .editLockInfo, .editLockInfoBySlug:
            return self.lockInfoRequestPath()
        
        }
    }
    
    /// Determine whether the specified request type and path elements the data associated with the current
    /// enumeration value
    public func matches(requestType: RequestType, components: [String]) -> Bool {
        
        // No need to handle the .unknown case, it will never be a match
        if self == .unknown {
            return false
        }
        
        // Bail out early if the request types don't match.
        // Can't match a GET with a POST, for example
        let current = self.requestPath()
        if current.requestType != requestType {
            return false
        }
        
        // Turn the path string into a components array
        // Any path element starting with "{" will be ignored
        // The net result is that if a path looks like this:
        //     foo/{id}/bar
        // Then we want to create an array like this:
        // [0] = foo
        // [1] = ""
        // [2] = bar
        let templateComponents = current
            .path
            .components(separatedBy: "/")
            .map { $0.starts(with: "{") ? "" : $0 }
        
        return equals(template: templateComponents, components)
        
    }
    
    public func equals(template: [String], _ right: [String]) -> Bool {
        // Can't be a match if the array counts are different
        if template.count != right.count {
            return false
        }
        
        // At this point, all is well. Request types are the same.
        // Number of items in the path is the same.
        // Now start testing each element.
        // Bail out as soon as the first "failure" takes place
        var returnValue = true
        for index in template.indices {
            
            let testValue = template[index]
            if !testValue.isEmpty {
                if testValue != right[index] {
                    returnValue = false
                    break
                }
            }
        }
        
        return returnValue
    }
    
    public static func key(for request: URLRequest) -> String? {
        
        guard let url = request.url,
            let requestMethod = request.httpMethod,
            let httpMethod = RequestType(rawValue: requestMethod)
            else {
                return nil
        }
        
        var simplePath = url.path.replacingOccurrences(of: LibraryPathConstants.baseManagementPath, with: "")
        simplePath = simplePath.replacingOccurrences(of: LibraryPathConstants.baseDeliveryPath, with: "")
        simplePath = simplePath.replacingOccurrences(of: LibraryPathConstants.baseSystemPath, with: "")
        
        let componentsToTest = simplePath.components(separatedBy: "/")
            .filter { !$0.isEmpty }
            .dropFirst()
            .map { $0 }
        
        let returnValue = SupportedURLOverrides.allCases.first {
            $0.matches(requestType: httpMethod, components: componentsToTest)
        }
        
        return returnValue?.rawValue 
    }
}

extension SupportedURLOverrides {
    func itemsRequestPath() -> RequestPathStruct {
        switch self {
            
        case .items:
            return RequestPathStruct("items")
            
        case .item:
            return RequestPathStruct("items/{id}")
            
        case .createItem:
            return RequestPathStruct(.post, "items")
            
        case .editItem:
            return RequestPathStruct(.put, "items/{id}")
            
        case .deleteItem:
            return RequestPathStruct(.delete, "items/{id}")
            
        default:
            return RequestPathStruct("")
        }
    }
    
    func channelsRequestPath() -> RequestPathStruct {
        switch self {
        case .channel:
            return RequestPathStruct("channels/{id}")
            
        case .channels:
            return RequestPathStruct("channels")
            
        case .createChannel:
            return RequestPathStruct(.post, "channels")
            
        case .editChannel:
            return RequestPathStruct(.put, "channels/{id}")
            
        case .deleteChannel:
            return RequestPathStruct(.delete, "channels/{id}")
            
        case .channelPermissions:
            return RequestPathStruct("channels/{id}/permissions")
            
        default:
            return RequestPathStruct("")
        }
    }
    
    func repositoriesRequestPath() -> RequestPathStruct {
        switch self {
        case .repository:
            return RequestPathStruct("repositories/{id}")
            
        case .repositories:
            return RequestPathStruct("repositories")
            
        case .createRepository:
            return RequestPathStruct( .post, "repositories")
            
        case .editRepository:
            return RequestPathStruct( .put, "repositories/{id}")
            
        case .deleteRepository:
            return RequestPathStruct( .delete, "repositories/{id}")
            
        case .repositoryPermissions:
            return RequestPathStruct("repositories/{id}/permissions")
            
        default:
            return RequestPathStruct("")
        }
    }
    
    func collectionsRequestPath() -> RequestPathStruct {
        switch self {
        case .collection:
            return RequestPathStruct("repositories/{id}/collections/{collectionId}")
            
        case .collections:
            return RequestPathStruct("repositories/{id}/collections")
            
        case .createCollection:
            return RequestPathStruct( .post, "repositories/{id}/collections")
            
        case .editCollection:
            return RequestPathStruct( .put, "repositories/{id}/collections/{collectionId}")
            
        case .deleteCollection:
            return RequestPathStruct( .delete, "repositories/{id}/collections/{collectionId}")
            
        case .collectionPermissions:
            return RequestPathStruct("repositories/{id}/collections/{collectionId}/permissions")
            
        default:
            return RequestPathStruct("")
        }
    }
    
    func bySlugRequestPath() -> RequestPathStruct {
        switch self {
        case .assetBySlug:
            return RequestPathStruct("items/.by.slug/{id}")
            
        default:
            return RequestPathStruct("")
        }
    }
    
    func typesRequestPath() -> RequestPathStruct {
        switch self {
        case .type:
            return RequestPathStruct("types/{name}")
            
        case .types:
            return RequestPathStruct("types")
            
        case .createType:
            return RequestPathStruct( .post, "types/{name}")
            
        case .editType:
            return RequestPathStruct( .put, "types/{name}")
            
        case .deleteType:
            return RequestPathStruct( .delete, "types/{name}")
            
        default:
            return RequestPathStruct("")
        }
    }
    
    func taxonomiesRequestPath() -> RequestPathStruct {
        switch self {
        case .taxonomies:
            return RequestPathStruct("taxonomies")
            
        case .taxonomy:
            return RequestPathStruct("taxonomies/{id}")
            
        case .createTaxonomy:
            return RequestPathStruct( .post, "taxonomies")
            
        case .editTaxonomy:
            return RequestPathStruct( .put, "taxonomies/{id}")
            
        case .deleteTaxonomy:
            return RequestPathStruct( .delete, "taxonomies/{id}")
            
        case .taxonomyCategory:
            return RequestPathStruct("taxonomies/{id}/categories/{id}")
            
        case .taxonomyCategories:
            return RequestPathStruct("taxonomies/{id}/categories")
            
        default:
            return RequestPathStruct("")
        }
    }
    
    func lockInfoRequestPath() -> RequestPathStruct {
        switch self {
        case .readLockInfo:
            return RequestPathStruct("items/{id}/lockInfo")
            
        case .readLockInfoBySlug:
            return RequestPathStruct("items/{id}/.by.slug/lockInfo")
            
        case .editLockInfo:
            return RequestPathStruct(.put, "items/{id}/lockInfo")
            
        case .editLockInfoBySlug:
            return RequestPathStruct(.put, "items/{id}/.by.slug/lockInfo")
            
        default:
            return RequestPathStruct("")
        }
    }

}

public struct RequestPathStruct {
    
    public var requestType: RequestType
    public var path: String
    
    public init(_ requestType: RequestType, _ path: String) {
        self.requestType = requestType
        self.path = path
    }
    
    public init(_ path: String) {
        self.requestType = .get
        self.path = path
    }
}
