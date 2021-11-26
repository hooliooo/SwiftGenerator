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

        let (formats, properties): ([DataFormat], [PropertyDescription]) = context.properties
            .reduce(
                into: ([DataFormat](), [PropertyDescription]())
            ) { (curr: inout (dataFormats: [DataFormat], properties: [PropertyDescription]), tuple: (String, JSONSchema)) -> Void in
                let (propertyName, schema): (String, JSONSchema)  = tuple
                let dataFormat: DataFormat = DataFormat.generateDataFormat(from: schema, objectName: name, propertyName: propertyName)

                let documentation: Documentation = Documentation(
                    schema.description ?? "No documentation",
                    format: Documentation.Format.multiline,
                    { Code.fragments([]) }
                )

                let description: PropertyDescription = PropertyDescription(
                    documentation: documentation,
                    property: StoredProperty(
                        access: Access.public,
                        isMutable: false,
                        name: propertyName,
                        type: dataFormat.stringValue,
                        value: nil
                    )
                )
                curr.dataFormats.append(dataFormat)
                curr.properties.append(description)
            }

        self.dataFormats = formats
        self.properties = properties
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
    public let properties: [PropertyDescription]

    /**
     The data formats of this object
     */
    public let dataFormats: [DataFormat]

}

extension ObjectSchema: Hashable {

    public static func == (lhs: ObjectSchema, rhs: ObjectSchema) -> Bool {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }

}
