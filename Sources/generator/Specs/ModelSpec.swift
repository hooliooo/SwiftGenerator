//
//  ModelSpec.swift
//
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 1.05.20.
//

import CodeBuilder
import Foundation
import OpenAPIKit

/**
 Decomposes the ObjectSchema into CodeRepresentable instances that represent documentation and a struct definition of the ObjectSchema
 - parameters:
    - schema: The ObjectSchema to be decomposed
 - returns:
    - A GroupFragment that represents an object described in the ObjectSchema
 */
func modelSpec(with schema: ObjectSchema) -> CodeRepresentable {
    let properties: [CodeRepresentable] = schema.properties.map { (property: PropertyDescription) -> GroupFragment in
        return GroupFragment(children: [property.documentation, property.property])
    }
    let enums: [CodeRepresentable] = schema.dataFormats
        .compactMap { (format: DataFormat) -> CodeRepresentable? in
            guard case let .enum(_, `enum`) = format else { return nil }
            return `enum`.code
        }

    let args: [(argument: Argument, doc: Documentation)] = schema.properties.map { ($0.property.asArgument, $0.documentation) }
    let parameters: [Parameter] = args.map { $0.argument.asParameter(documentation: $0.doc.content) }
    let doc: CodeRepresentable = documentationSpec(schema.documentation, format: .multiline)
    let spec: CodeRepresentable = structSpec(schema.name, access: .public, inheritingFrom: ["Hashable", "Codable"]) {
        documentationSpec(
            schema.documentation,
            format: Documentation.Format.multiline,
            parameters: parameters
        )
        initializerSpec(
            access: .public,
            arguments: args.map { $0.argument }
        )
        lineBreak()
        ForEach(properties) { $0 }
        lineBreak()
        ForEach(enums) { $0 }
    }
    return GroupFragment(children: [doc, spec])
}
