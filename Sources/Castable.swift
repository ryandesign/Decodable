//
//  Castable.swift
//  Decodable
//
//  Created by Johannes Lund on 2015-09-25.
//  Copyright © 2015 anviking. All rights reserved.
//

import Foundation

/// Attempt to cast an `AnyObject` to `T` or throw
///
/// - throws: `DecodingError.typeMismatch(expected, actual, metadata)`
public func cast<T>(_ object: AnyObject) throws -> T {
    guard let result = object as? T else {
        let metadata = DecodingError.Metadata(object: object)
        throw DecodingError.typeMismatch(expected: T.self, actual: object.dynamicType, metadata)
    }
    return result
}

public protocol DynamicDecodable {
    associatedtype DecodedType
    static var decoder: (AnyObject) throws -> DecodedType {get set}
}

extension Decodable where Self: DynamicDecodable, Self.DecodedType == Self {
    public static func decode(_ json: AnyObject) throws -> Self {
        return try decoder(json)
        
    }
}

extension String: Decodable, DynamicDecodable {
    public static var decoder: (AnyObject) throws -> String = { try cast($0) }
}
extension Int: Decodable, DynamicDecodable {
    public static var decoder: (AnyObject) throws -> Int = { try cast($0) }
}
extension Double: Decodable, DynamicDecodable {
    public static var decoder: (AnyObject) throws -> Double = { try cast($0) }
}
extension Bool: Decodable, DynamicDecodable {
    public static var decoder: (AnyObject) throws -> Bool = { try cast($0) }
}

private let iso8601DateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(localeIdentifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
}()

extension Date: Decodable, DynamicDecodable {
    public static var decoder: (AnyObject) throws -> Date = { object in
        let string = try String.decode(object)
        guard let date = iso8601DateFormatter.date(from: string) else {
            let metadata = DecodingError.Metadata(object: object)
            throw DecodingError.rawRepresentableInitializationError(rawValue: string, metadata)
        }
        return date
    }
}

extension NSDictionary: Decodable {
    public static func decode(_ json: AnyObject) throws -> Self {
        return try cast(json)
    }
}

extension NSArray: DynamicDecodable {
    public static var decoder: (AnyObject) throws -> NSArray = { try cast($0) }
    public static func decode(_ json: AnyObject) throws -> NSArray {
        return try decoder(json)
    }

}
