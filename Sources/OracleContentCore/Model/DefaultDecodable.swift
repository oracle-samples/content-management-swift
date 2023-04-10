// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Protocol to which the `DecodableDefault` property wrapper conforms
/// Allows for conforming objects to provide a default value when none is specified - either through initialization or while parsing JSON data
public protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    
    static var defaultValue: Value { get }
}

/// Namespacing enum which encapsulates property wrappers that provide default values for model properties
///
/// `DecodableDefault` is simply a namespacing wrapper in the form an enum
///  The type of defaut value is exposed through a series of typealiases which mask the inner details
///
///   This means a property in our model class can be annotated like:
///   ```swift
///    @DecodableDefault.EmptyString public var myStringValue
///   ```
public enum DecodableDefault {
    
    /// Property wrapper providing a default value for a property of a `DecodableDefaultSource` type.
    ///
    /// Generic over `Source` where `Source` conforms to `DecodableDefaultSource`
    /// Uptake is made a little simpler by exposing typealiases for each supported type
    ///
    /// For example:
    /// ```swift
    /// typealias EmptyString = Wrapper<Sources.EmptyString>
    /// ```
    /// This allows usage in uptaking code through property wrapper annotations on properties
    /// ```swift
    /// public struct Foo: Codable, SupportsEmptyInitializer {
    ///     @DecodableDefault.True      public var hasMore
    ///     @DecodableDefault.UIntZero  public var offset
    ///     @DecodableDefault.EmptyList public var items: [SingleFooValue]
    ///
    ///     public required override init() { }
    /// }
    /// ```
    ///
    /// Supported types include:
    /// `Int`, `Int64`, `UInt`, Double`, `Bool`, `String` and `Date
    @propertyWrapper
    public struct Wrapper<Source: DecodableDefaultSource> {

        /// Helper typealias to simplify signatures
        public typealias Value = Source.Value
        
        /// The actual default value to use for a particular `Source` type
        public var wrappedValue = Source.defaultValue
        
        public init() { }
        
        public init(_ value: Value) {
            self.wrappedValue = value
        }
    }
}

public extension DecodableDefault.Wrapper where Value == Int {
    /// DecodableDefault initializer supporting Int types
    init(_ val: Value) {
        self.wrappedValue = val
    }
}

public extension DecodableDefault.Wrapper where Value == Int64 {
    /// DecodableDefault intializer supporting Int64 types
    init(_ val: Value) {
        self.wrappedValue = val
    }
}

public extension DecodableDefault.Wrapper where Value == Double {
    /// DecodableDefault intializer supporting Double types
    init(_ val: Value) {
        self.wrappedValue = val
    }
}

public extension DecodableDefault.Wrapper where Value == UInt {
    /// DecodableDefault intializer supporting UInt types
    init(_ val: Value) {
        self.wrappedValue = val
    }
}

public extension DecodableDefault.Wrapper where Value == String {
    /// DecodableDefault intializer supporting String types
    init(_ val: Value) {
        self.wrappedValue = val 
    }
}

public extension DecodableDefault.Wrapper where Value == Date {
    /// DecodableDefault intializer supporting Date types
    init(_ val: Value) {
        self.wrappedValue = val
    }
}

extension DecodableDefault.Wrapper: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension DecodableDefault {
    public typealias Source = DecodableDefaultSource
    public typealias List = Decodable & ExpressibleByArrayLiteral
    public typealias Map = Decodable & ExpressibleByDictionaryLiteral
    public typealias SupportEmptyInit = Codable & SupportsEmptyInitializer

    /// Defines the supported default values 
    public enum Sources: CaseIterable {
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }

        public enum False: Source {
            public static var defaultValue: Bool { false }
        }

        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }

        public enum EmptyList<T: List>: Source {
            public static var defaultValue: T { [] }
        }

        public enum EmptyMap<T: Map>: Source {
            public static var defaultValue: T { [:] }
        }
        
        public enum IntZero: Source {
            public static var defaultValue: Int { 0 }
        }
        
        public enum Int64Zero: Source {
            public static var defaultValue: Int64 { 0 }
        }
        
        public enum UIntZero: Source {
            public static var defaultValue: UInt { 0 }
        }
        
        public enum DoubleZero: Source {
            public static var defaultValue: Double { 0 }
        }
        
        public enum EmptyInit<T: SupportEmptyInit>: Source {
            public static var defaultValue: T { T() }
        }
        
        public enum DistantPastDate: Source {
            static public var defaultValue: Date { .distantPast }
        }
        
        public enum DistantFutureDate: Source {
            static public var defaultValue: Date { .distantFuture }
        }
    }
}

extension DecodableDefault {
    public typealias True = Wrapper<Sources.True>
    public typealias False = Wrapper<Sources.False>
    public typealias EmptyString = Wrapper<Sources.EmptyString>
    public typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    public typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
    public typealias IntZero = Wrapper<Sources.IntZero>
    public typealias Int64Zero = Wrapper<Sources.Int64Zero>
    public typealias UIntZero = Wrapper<Sources.UIntZero>
    public typealias DoubleZero = Wrapper<Sources.DoubleZero>
    public typealias EmptyInit<T: SupportEmptyInit> = Wrapper<Sources.EmptyInit<T>>
    public typealias DistantPastDate = Wrapper<Sources.DistantPastDate>
    public typealias DistantFutureDate = Wrapper<Sources.DistantFutureDate>
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        if type(of: self) == DecodableDefault.Wrapper<OracleContentCore.DecodableDefault.Sources.DistantPastDate>.self ||
           type(of: self) == DecodableDefault.Wrapper<OracleContentCore.DecodableDefault.Sources.DistantFutureDate>.self {
            // "Regular" dates must be encoded as DateContainer
            guard let foundDate = wrappedValue as? Date else {
                throw OracleContentError.dataConversionFailed
            }
            
            let dc = DateContainer(date: foundDate)
            var container = encoder.singleValueContainer()
            try container.encode(dc)
        } else {
            // all other data types
            var container = encoder.singleValueContainer()
            try container.encode(wrappedValue)
        }
    }
}
