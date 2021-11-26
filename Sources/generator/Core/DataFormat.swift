//
//  DataFormat.swift
//
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 1.05.20.
//

import CodeBuilder
import Foundation
import OpenAPIKit

/**
 A DataFormat decomposes information from a JSONSchema into a string representation usable for CodeBuilder
 */
public enum DataFormat {
    /**
     An array type with the associated value as the string representation of the element type
     */
    case array(String)

    /**
     An enum type with the object's name as a the parentName, the name of the enum, the data type for the enum, and the acceptable values for that enum
     */
    case `enum`(parentName: String, enum: AnyEnum)

    /**
     An object type.
     */
    case object(String)

    // MARK: Static Methods
    /**
     Generates a DataFormat instance from the information provided by a JSON Schema
     - parameters:
        - schema      : The JSONSchema being parsed
        - object      : The name of the object described by the JSONSchema
        - propertyName: The name of the property of the object
     - returns:
        A DataFormat instance with information necessary to generate a proper Swift code string
     */
    public static func generateDataFormat(from schema: JSONSchema, objectName: String, propertyName: String) -> DataFormat {
        switch schema {
            case let .array(_, context):
                if let elementType = context.items?.jsonTypeFormat {
                    return .array(String(describing: elementType.swiftType))
                } else if case let .reference(typeSchema) = context.items, let typeName = typeSchema.name {
                    return .array(typeName)
                } else {
                    fatalError()
                }
            case .reference(let typeSchema):
                guard let typeName = typeSchema.name else { fatalError() }
                return .object(typeName)
            case let .string(format, _):
                if let allowedValues = format.allowedValues {
                    return .enum(
                        parentName: objectName.capitalized,
                        enum: AnyEnum(
                            access: Access.public,
                            enum: RawValueEnum<String>(
                                name: propertyName.capitalized,
                                cases: allowedValues.map { RawValueEnumCase(name: $0.description, value: nil) }
                            ),
                            inheritingFrom: ["Codable"]
                        )
                    )
                } else {
                    let type: String = {
                        switch format.format {
                            case .binary, .byte: return "Data"
                            case .date, .dateTime: return "Date"
                            default: return "String"
                        }
                    }()
                    return .object("\(type)\(schema.nullable ? "?" : "")")
                }
            default:
                guard let format = schema.jsonTypeFormat else { fatalError() }
                return .object("\(String(describing: format.swiftType))\(schema.nullable ? "?" : "")")
        }
    }

    /**
     The string representation of the cases in a format suitable for CodeBuilder
     */
    public var stringValue: String {
        switch self {
            case .array(let type):
                return "[\(type)]"
            case let .enum(parentName, `enum`):
                return "\(parentName).\(`enum`.name)"
            case .object(let type):
                return type
        }
    }
}
