// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore

/**
 An asset in the ``OracleContentDelivery`` library is either a digital asset or a structured content item.
 
 You can determine the type of the asset by testing either of the following two properties
 
 ```swift
 if asset.isDigitalAsset {
    // do something
 }
 
 if asset.isContentItem {
    // do something
 }
 ```
 
 You can obtain access to the standard fields of a digital asset  by accessing the `digitalAssetFields` property
 ```swift
 if let fields = asset.digitalAssetFields {
    // fields is of type `EmbeddedDigitalAssetMetadata<AssetType>`
    // This allows for dot-property access to digital asset standard fields
 
    let metadata = fields.metadata
 }
 ```
 
 While you could obtain access to a content item's fields through a similar `contentItemFields` property, there is a simpler alternative available that allows for much easier access and requires less uptaking code. As a bonus, this alternative also allows for the same access to a digital assets custom/user-defined fields.
 
 You simply call the `customField` accessor and pass in the name of the field.  You must explicity specify the data type expected.  See the `OracleContentDeliveryTests` unit test named `AssetConvenienceMethodTests` for full examples.
 
 ```swift
 let boolValue: Bool = try asset.customField("field1")
 let stringValue: String = try asset.customField("field2")
 let assetValue: Asset = try asset.customField("field3")
 let arrayOfAssetsValues: [Asset] = try asset.customField("field4")
 let arrayOfStringValues: [String] = try asset.customField("field5")
 let dateValue: Date = try asset.customField("field6")
 
 let int64Value = try asset.customField("field7") as Int64
 
 ```
 */
open class Asset: NSObject, Codable, SupportsEmptyInitializer, ImplementsCustomFields {
    /// Typealias to the current class. Utilized by generic downstream objects to track the type of object being parsed
    public typealias AssetType = Asset
    
    /// Fields to be parsed from the web service response 
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case desc = "description"
        case type
        case typeCategory
        case slug
        case language
        case translatable
        case createdDate
        case updatedDate
        case fieldsEnum = "fields"
        case itemVariations
        case taxonomies
        case renditions
        case mimeType
        case fileGroup
        case links
    }
    
    /// The id of the item
    @DecodableDefault.EmptyString public var identifier: String
    
    /// Name of the item
    @DecodableDefault.EmptyString public var name: String
    
    /// Description of the item
    @DecodableDefault.EmptyString public var desc: String
    
    /// Indicates whether the item is translatable 
    @DecodableDefault.False public var translatable: Bool
    
    /// Language of the item
    @DecodableDefault.EmptyString public var language
    
    /// Name of the content type describing this item. Used to differentiate between a digital asset (which may contain user defined fields) and a structured content type.
    @DecodableDefault.EmptyString public var type: String
    
    /// The type category of the item
    @DecodableDefault.EmptyString public var typeCategory: String

    /// A URL part that identifies content item in human-readable format.
    @DecodableDefault.EmptyString public var slug: String
    
    /// mimeType of the item. For content items it will be contentItem, for digital assets it will be something like image/png
    @DecodableDefault.EmptyString public var mimeType: String
    
    /// Group of the items. Few possible values are contentItem, Images, Files, Videos
    @DecodableDefault.EmptyString public var fileGroup: String
    
    /// Links of the resource
    @DecodableDefault.EmptyList public var links: [Link]
    
    /// Taxonomies of the item
    @DecodableDefault.EmptyInit public var taxonomies: TaxonomiesBean
    
    /// Renditions of the item
    @DecodableDefault.EmptyInit public var renditions: ItemSubResourceRendition
    
    /// Variations of the item
    @DecodableDefault.EmptyList public var itemVariations: [ItemVariation]
    
    /// First published date of the item on the channel requested.
    public var createdDate: Date?
    
    /// Last published date of the item on the channel requested.
    public var updatedDate: Date?
    
    /// These are fields created by the user when the Type is defined. 
    internal var fieldsEnum: FieldsData<AssetType>?
    
    /// Returns true if the asset is a digital asset
    public var isDigitalAsset: Bool {
        return self.typeCategory == "DigitalAssetType" || (self.typeCategory.isEmpty && self.type == "DigitalAsset")
    }
    
    /// Returns true if the asset is a content item
    public var isContentItem: Bool {
        return !self.isDigitalAsset
    }
    
    public required override init() { }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
    
        self.identifier     = try container.decode(String.self, forKey: .identifier)
        self.name           = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.desc           = try container.decodeIfPresent(String.self, forKey: .desc) ?? ""
        self.translatable   = try container.decodeIfPresent(Bool.self, forKey: .translatable) ?? false
        self.language       = try container.decodeIfPresent(String.self, forKey: .language) ?? ""
        self.type           = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        self.typeCategory   = try container.decodeIfPresent(String.self, forKey: .typeCategory) ?? ""
        self.slug           = try container.decodeIfPresent(String.self, forKey: .slug) ?? ""
        self.links          = try container.decodeIfPresent([Link].self, forKey: .links) ?? []
        self.taxonomies     = try container.decodeIfPresent(TaxonomiesBean.self, forKey: .taxonomies) ?? TaxonomiesBean()
        self.renditions     = try container.decodeIfPresent(ItemSubResourceRendition.self, forKey: .renditions) ?? ItemSubResourceRendition()
        self.itemVariations = try container.decodeIfPresent([ItemVariation].self, forKey: .itemVariations) ?? []
        
        self.mimeType       = try container.decodeIfPresent(String.self, forKey: .mimeType) ?? ""
        self.fileGroup      = try container.decodeIfPresent(String.self, forKey: .fileGroup) ?? ""
       
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
        self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
    
        if self.typeCategory == "DigitalAssetType" || (self.typeCategory.isEmpty && self.type == "DigitalAsset") {
            
            if let foundFields = try container.decodeIfPresent(EmbeddedDigitalAssetMetadata<AssetType>.self, forKey: .fieldsEnum) {
                self.fieldsEnum = .digitalAssetFields(foundFields)
            }
            
        } else {
            if let foundFields = try container.decodeIfPresent([String: JSONValue<AssetType>].self, forKey: .fieldsEnum) {
                self.fieldsEnum = .contentItemFields(foundFields)
            }
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.desc, forKey: .desc)
        try container.encode(self.translatable, forKey: .translatable)
        try container.encode(self.language, forKey: .language)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.typeCategory, forKey: .typeCategory)
        try container.encode(self.slug, forKey: .slug)
        try container.encode(self.links, forKey: .links)
        try container.encode(self.taxonomies, forKey: .taxonomies)
        try container.encode(self.renditions, forKey: .renditions)
        try container.encode(self.itemVariations, forKey: .itemVariations)
        try container.encode(self.createdDate, forKey: .createdDate)
        try container.encode(self.updatedDate, forKey: .updatedDate)
        try container.encode(self.fieldsEnum, forKey: .fieldsEnum)
        try container.encode(self.mimeType, forKey: .mimeType)
        try container.encode(self.fileGroup, forKey: .fileGroup)
    }
}

extension Asset {
    
    /// These are fields created by the user when the Type is defined.
    public var digitalAssetFields: EmbeddedDigitalAssetMetadata<AssetType>? {
        
        get {
            guard let foundEnum = self.fieldsEnum else {
                return nil
            }
            
            switch foundEnum {
            case .digitalAssetFields(let value):
                return value
                
            default:
                return nil
            }
        }
        
        set {
            if let foundValue = newValue {
                self.fieldsEnum = .digitalAssetFields(foundValue)
            } else {
                self.fieldsEnum = nil
            }
        }
    }
    
    /// Returns the structure representing the Thumbnail of a digital asset.
    /// Returns nil if accessed for the structured content item
    public var thumbnailRendition: EmbeddedRenditionFormat? {
        let rendition = self.digitalAssetFields?
            .renditions
            .first { $0.name == "Thumbnail" }
        
        let renditionFormat = rendition?.formats
            .first { $0.format == "png" || $0.format == "jpg" }
        
        return renditionFormat
    }
    
    /// These are fields created by the user when the Type is defined.
    public var contentItemFields: [String: JSONValue<AssetType>]? {
        
        get {
            guard let foundEnum = self.fieldsEnum else {
                return nil
            }
            
            if case let FieldsData.contentItemFields(value) = foundEnum {
                
                let returnValue = value.mapValues { JSONValue<AssetType>(any: $0.value()) }
                return returnValue
            }
            return nil
        }
        
        set {
            if let foundValue = newValue {
                self.fieldsEnum = .contentItemFields(foundValue)
            } else {
                self.fieldsEnum = nil
            }
        }
    }
}

extension Asset: SupportsStringDescription {
    public func stringDescription() -> String {
        return "\(self.type): \(self.name)"
    }
}
