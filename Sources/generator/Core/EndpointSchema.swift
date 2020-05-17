//
//  EndpointSchema.swift
//
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 17.05.20.
//

import CodeBuilder
import Foundation
import OpenAPIKit

public struct EndpointSchema {

    private static let unneededCharacters: CharacterSet = CharacterSet(charactersIn: "{}")

    private static func extract(schema: ObjectSchema, arguments: inout [Argument], customRequestBodies: inout Set<ObjectSchema>) {
        arguments.append(
            Argument(
                name: "\(schema.name.lowercased())",
                type: schema.name
            )
        )
        customRequestBodies.insert(schema)
    }

    public init(path: OpenAPI.Path, item: OpenAPI.PathItem, schemas: [ObjectSchema]) {
        self.path = path.rawValue.components(separatedBy: EndpointSchema.unneededCharacters.inverted).joined()
        self.item = item

        var customRequestBodies: Set<ObjectSchema> = []
        for endpoint in item.endpoints {
            let operation: OpenAPI.PathItem.Operation = endpoint.operation
            let methodName: String = operation.operationId ?? "\(endpoint.verb.rawValue.lowercased())UnknownEntity"
            var arguments: [Argument] = []

            if let requestBody = operation.requestBody {
                switch requestBody {
                    case .a(let reference): // Internal object
                        switch reference {
                            case .external(let url):
                                fatalError("Not implemented yet")
                            case .internal(let innerReference):
                                fatalError("Not implemented yet")
                        }
                    case .b(let request): // Build new struct
                        for (key, value) in request.content where key != .xml {
                            switch value.schema {
                                case .a(let innerJSONReference):
                                    let schema: ObjectSchema = schemas.first(where: { $0.name == innerJSONReference.name })!
                                    EndpointSchema.extract(schema: schema, arguments: &arguments, customRequestBodies: &customRequestBodies)
                                case .b(let schema):
                                    switch schema {
                                        case let .object(format, context):
                                            let schema: ObjectSchema = ObjectSchema(
                                                name: "\(methodName.capitalizeCamelCase())Input",
                                                format: format,
                                                context: context
                                            )
                                            EndpointSchema.extract(schema: schema, arguments: &arguments, customRequestBodies: &customRequestBodies)
                                        case let .array(_, context):
                                            if let items = context.items {
                                                let dataFormat = ObjectSchema.generateDataFormat(from: items, objectName: "", propertyName: "")
                                                arguments.append(
                                                    Argument(
                                                        name: "\(dataFormat.stringValue.lowercased())s",
                                                        type: "[\(dataFormat.stringValue)]"
                                                    )
                                                )
                                            }
                                        default:
                                            fatalError("Not handled: \(value)")
                                }
                            }
                        }
                }
            }
            print(endpoint)
        }
        self.methods = []
    }

    public let path: String
    public let item: OpenAPI.PathItem

    public let methods: [HttpClientMethod]
}

public struct HttpClientMethod {

    public let name: String

    public let arguments: [Argument]

    public let responseValue: String?

    public let helperStructs: [Any]

}

public struct AnyRequestBody {

    public let name: String

    public let properties: [StoredProperty]

    public let contentType: OpenAPI.ContentType

}

extension String {
    func titleCase() -> String {
        return self
            .replacingOccurrences(
                of: "([A-Z])",
                with: " $1",
                options: .regularExpression,
                range: range(of: self)
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }

    func capitalizeCamelCase() -> String{
        return self
            .titleCase()
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .joined()
    }
}
