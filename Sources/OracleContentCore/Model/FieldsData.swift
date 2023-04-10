// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Enumeration that defines the two types of fields data that may exist for an Asset
/// Digital assets will contain values for digitalAssetFields
/// Content items will contain values for contentItemFields
public enum FieldsData<AssetType: Codable & SupportsStringDescription>: Codable {
    
    /// Field values for Assets which are Digital Assets
    case digitalAssetFields(EmbeddedDigitalAssetMetadata<AssetType>)
    
    /// Field values for Assets which are Content Items
    case contentItemFields([String: JSONValue<AssetType>])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(EmbeddedDigitalAssetMetadata<AssetType>.self) {
            self = .digitalAssetFields(value)
        } else if let value = try? container.decode([String: JSONValue<AssetType>].self) {
            self = .contentItemFields(value)
        }
        else {
            throw DecodingError.typeMismatch(JSONValue<AssetType>.self,
                                             DecodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Not valid fields JSON"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case let .digitalAssetFields(metadata):
            try container.encode(metadata)
        
        case let .contentItemFields(dict):
            try container.encode(dict)
        }
    }
}

/// Model values representing the fields for a digital asset
public class EmbeddedDigitalAssetMetadata<AssetType: Codable & SupportsStringDescription>: NSObject, Codable, SupportsEmptyInitializer {
    
    /// Represents dynamic keys that may contain user-defined custom data
    /// The general strategy is to first decode based on the static CodingKeys.
    /// The will obtain all of the items that must exist in a digital asset.
    /// Following that we look at the DynamicCodingKeys and skip over any that are contained in CodingKey
    /// That will leave us with keys
    private struct DynamicCodingKeys: CodingKey {
        
            // Use for string-keyed dictionary
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
            // Use for integer-keyed dictionary
        var intValue: Int?
        
        init?(intValue: Int) {
                // We are not using this, thus just return nil
            return nil
        }
    }
    
    /// Hard-coded compile time properties that must exist in a digital asset
    enum CodingKeys: String, CodingKey {
        case size
        case metadata
        case native
        case renditions
        case mimeType
        case version
        case fileType
        case fileGroup
        case advancedVideoInfo
        case customFields
    }
    
    // No defaults provided, otherwise unable to differentiate between
    // digital asset values and content item values
    public var metadata: EmbeddedMetadata
    public var size: Int
    public var native: EmbeddedNative
    public var renditions: [EmbeddedRendition]
    public var mimeType: String
    public var version: String
    public var fileType: String
    public var fileGroup: String?
    public var customFields = [String: JSONValue<AssetType>]()
    @DecodableDefault.EmptyInit public var advancedVideoInfo: EmbeddedAdvancedVideoInfo
    
    /// Required initializer
    public required override init() {
        self.metadata = EmbeddedMetadata()
        self.size = 0
        self.native = EmbeddedNative()
        self.renditions = [EmbeddedRendition]()
        self.mimeType = ""
        self.version = ""
        self.fileType = ""
    }
    
    public required init(from decoder: Decoder) throws {
        
            // handle the "must have" values
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.metadata = try container.decodeIfPresent(EmbeddedMetadata.self, forKey: .metadata) ?? EmbeddedMetadata()
        self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 0
        self.native = try container.decodeIfPresent(EmbeddedNative.self, forKey: .native) ?? EmbeddedNative()
        self.renditions = try container.decodeIfPresent( [EmbeddedRendition].self, forKey: .renditions) ?? []
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType) ?? ""
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? ""
        self.fileType = try container.decodeIfPresent(String.self, forKey: .fileType ) ?? ""
        self.fileGroup = try container.decodeIfPresent(String.self, forKey: .fileGroup)
        
            // this will never parse - included in CodingKeys only so that we can encode easily
        self.customFields = try container.decodeIfPresent([String: JSONValue<AssetType>].self, forKey: .customFields) ?? [:]
        
        super.init()
        
        self.advancedVideoInfo = try container.decodeIfPresent(EmbeddedAdvancedVideoInfo.self, forKey: .advancedVideoInfo) ?? EmbeddedAdvancedVideoInfo()
        
            // handle any "custom fields that may be present"
        let customContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        for key in customContainer.allKeys {
            
                // If we can create a CodingKey from the current key then that means the key has already been handled in the decoding above
                // However, if we cannot create CodingKey from the current key then we have a custom value that must be parsed
            if CodingKeys(rawValue: key.stringValue) == nil {
                let decodedObject = try customContainer.decode(JSONValue<AssetType>.self,
                                                               forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
                self.customFields[key.stringValue] = decodedObject
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.metadata, forKey: .metadata)
        try container.encode(self.size, forKey: .size)
        try container.encode(self.native, forKey: .native)
        try container.encode(self.renditions, forKey: .renditions)
        try container.encode(self.mimeType, forKey: .mimeType)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.fileType, forKey: .fileType)
        try container.encode(self.fileGroup, forKey: .fileGroup)
        try container.encode(self.customFields, forKey: .customFields)
        try container.encode(self.advancedVideoInfo, forKey: .advancedVideoInfo)
    }
}

/// Metadata for a digital asset
public class EmbeddedMetadata: NSObject, Codable, SupportsEmptyInitializer {
    
    enum CodingKeys: String, CodingKey {
        case width
        case height
    }
    
    /// Metadata for digital asset width
    @DecodableDefault.EmptyString public var width: String
    
    /// Metadata for digital asset height
    @DecodableDefault.EmptyString public var height: String
    
    /// Required initializer
    public required override init() { }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        super.init()
        
        if let stringVal = try? container.decode(String.self, forKey: .width) {
            self.width = stringVal
        } else {
            let doubleVal = try container.decode(Double.self, forKey: .width)
            self.width = String(doubleVal)
        }
        
        if let stringVal = try? container.decode(String.self, forKey: .height) {
            self.height = stringVal
        } else {
            let doubleVal = try container.decode(Double.self, forKey: .height)
            self.height = String(doubleVal)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
    }
}

/// Provides links to the Native rendition of a digital asset
public class EmbeddedNative: NSObject, Codable, SupportsEmptyInitializer {
    
    @DecodableDefault.EmptyList public var links: [Link]
    
    public required override init() { }
}

/// An available rendition for a digital asset. A rendition may have multiple formats
public class EmbeddedRendition: NSObject, Codable, SupportsEmptyInitializer {
    @DecodableDefault.EmptyString public var name: String
    @DecodableDefault.EmptyList public var formats: [EmbeddedRenditionFormat]
    @DecodableDefault.EmptyString public var type: String
    
    public required override init() { }
}

/// An individual format for an available digital asset rendition
public class EmbeddedRenditionFormat: NSObject, Codable, SupportsEmptyInitializer {
    @DecodableDefault.EmptyString public var format: String
    @DecodableDefault.IntZero     public var size: Int
    @DecodableDefault.EmptyString public var mimeType: String
    @DecodableDefault.EmptyInit public var metadata: EmbeddedMetadata
    @DecodableDefault.EmptyList public var links: [Link]
    
    public required override init() { }
}

/// Provides information about the AdvancedVideo provider
public class EmbeddedAdvancedVideoInfo: NSObject, Codable, SupportsEmptyInitializer {
    @DecodableDefault.EmptyString public var provider: String
    @DecodableDefault.EmptyInit public var properties: EmbeddedAdvancedVideoInfoProperties
    
    public required override init() { }
}

/// Defines the properties for an AdvancedVideo provider
public class EmbeddedAdvancedVideoInfoProperties: NSObject, Codable, SupportsEmptyInitializer {
    
    enum CodingKeys: String, CodingKey {
        case duration
        case videoStripProperties
        case videoExtension = "extension"
        case searchText
        case name
        case status
        case entryId
        case endpoint
        case partner
        case player
    }
    
    @DecodableDefault.DoubleZero public var duration: Double
    @DecodableDefault.EmptyString public var videoStripProperties: String
    @DecodableDefault.EmptyString public var videoExtension: String
    @DecodableDefault.EmptyString public var searchText: String
    @DecodableDefault.EmptyString public var name: String
    @DecodableDefault.EmptyString public var status: String
    @DecodableDefault.EmptyString public var entryId: String
    @DecodableDefault.EmptyString public var endpoint: String
    @DecodableDefault.EmptyInit public var partner: EmbeddedAdvancedVideoInfoPropertiesPartner
    @DecodableDefault.EmptyInit public var player: EmbeddedAdvancedVideoInfoPropertiesPlayer
    
    public required override init() { }
}

public class EmbeddedAdvancedVideoInfoPropertiesPartner: NSObject, Codable, SupportsEmptyInitializer {
    @DecodableDefault.EmptyString public var id: String
    
    public required override init() { }
    
    public init(id: String) {
        super.init()
        self.id = id
    }
}

public class EmbeddedAdvancedVideoInfoPropertiesPlayer: NSObject, Codable, SupportsEmptyInitializer {
    @DecodableDefault.EmptyString public var id: String
    
    public required override init() { }
    
    public init(id: String) {
        super.init()
        self.id = id
    }
}

