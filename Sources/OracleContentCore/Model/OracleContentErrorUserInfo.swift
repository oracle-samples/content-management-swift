// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

public class OracleContentErrorUserInfo: NSObject, Codable, SupportsEmptyInitializer {
    enum CodingKeys: String, CodingKey {
        case title
        case detail
        case errorCode = "o:errorCode"
        case errorDetails = "o:errorDetails"
        case type
        case status
    }
    
    @DecodableDefault.EmptyString public var title: String
    @DecodableDefault.EmptyString public var detail: String
    @DecodableDefault.EmptyString public var errorCode: String
    @DecodableDefault.EmptyList public var errorDetails: [OracleContentErrorDetails]
    @DecodableDefault.EmptyString public var type: String
    @DecodableDefault.IntZero     public var status: Int
    
    public required override init() { }
}

public class OracleContentErrorDetails: NSObject, Codable, SupportsEmptyInitializer {
    enum CodingKeys: String, CodingKey {
        case title
        case detail
        case errorCode = "o:errorCode"
        case errorPath = "o:errorPath"
        case type
    }
    
    @DecodableDefault.EmptyString public var title: String
    @DecodableDefault.EmptyString public var detail: String
    @DecodableDefault.EmptyString public var errorCode: String
    @DecodableDefault.EmptyString public var errorPath: String
    @DecodableDefault.EmptyString public var type: String
    
    public required override init() { }
    
}
