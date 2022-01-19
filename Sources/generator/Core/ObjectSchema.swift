//
//  ObjectSchema.swift
//  
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 1.05.20.
//

import CodeBuilder
import Foundation
import OpenAPIKit

/**
 A representation of an object from the OpenAPI Schema
 */
public struct ObjectSchema {

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
                            spec: RawValueEnum<String>(
                                name: propertyName.capitalized,
                                cases: allowedValues.map { RawValueEnumCase(name: $0.description, value: nil) }
                            ),
                            inheritingFrom: ["Codable"]
                        )
                    )
                } else {
                    var type: String {
                        switch format.format {
                            case .binary, .byte: return "Data"
                            case .date, .dateTime: return "Date"
                            default: return "String"
                        }
                    }
                    return .object("\(type)\(schema.nullable ? "?" : "")")
                }
            default:
                guard let format = schema.jsonTypeFormat else { fatalError() }
                return .object("\(String(describing: format.swiftType))\(schema.nullable ? "?" : "")")
        }
    }

    // Initializer
    /**
     Creates an ObjectSchema representation of a JSONSchema of an object
     - parameters:
        - name   : The name of the object
        - format : The format of the object
        - context: The context of the object
     */
    public init(name: String, format: JSONSchema.CoreContext<JSONTypeFormat.ObjectFormat>, context: JSONSchema.ObjectContext) {
        self.name = name
        self.format = format
        self.context = context

        if let description = format.description {
            self.documentation = description
        } else {
            self.documentation = "No documentation"
        }
        self.dataFormats = context.properties.map { (propertyName: String, schema: JSONSchema) -> DataFormat in
            ObjectSchema.generateDataFormat(from: schema, objectName: name, propertyName: propertyName)
        }
        self.properties = context.properties.map { (propertyName: String, schema: JSONSchema) -> PropertySchema in
            var documentation: Documentation {
                guard let description = schema.description else {
                    return Documentation("No documentation", format: Documentation.Format.multiline, { Code.fragments([]) }) }
                return Documentation(description, format: Documentation.Format.multiline, { Code.fragments([]) })
            }

            let type: String = ObjectSchema.generateDataFormat(from: schema, objectName: name, propertyName: propertyName).stringValue
            let defaultValue: String? = {
                if let value = schema.defaultValue?.value {
                    return "\(value)"
                } else {
                    return nil
                }
            }()
            return PropertySchema(
                documentation: documentation,
                property: StoredProperty(
                    access: Access.public,
                    isMutable: false,
                    name: propertyName,
                    type: type,
                    value: defaultValue
                )
            )
        }
    }

    // MARK: Stored Properties
    /**
     The name of the object defined by the JSONSchema
     */
    public let name: String

    /**
     The documentation describing the object
     */
    public let documentation: String

    /**
     The ObjectFormat of this schema
     */
    public let format: JSONSchema.CoreContext<JSONTypeFormat.ObjectFormat>

    /**
     The ObjectContext of this schema
     */
    public let context: JSONSchema.ObjectContext

    /**
     The properties of this object
     */
    public let properties: [PropertySchema]

    /**
     The data formats of this object
     */
    public let dataFormats: [DataFormat]

}
