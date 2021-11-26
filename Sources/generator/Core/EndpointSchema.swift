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
import os.log

fileprivate extension OSLog {

    static let endpointLogger = OSLog(subsystem: "com.swift.generator", category: "endpointschema")

}

public struct EndpointSchema {

    private static let unneededCharacters: CharacterSet = CharacterSet(charactersIn: "{}")

    public init(path: OpenAPI.Path, item: OpenAPI.PathItem, schemas: [ObjectSchema]) {
        self.path = path.rawValue.components(separatedBy: EndpointSchema.unneededCharacters.inverted).joined()
        self.item = item

        var customRequestBodies: Set<ObjectSchema> = []

        self.methods = item.endpoints.map { (endpoint: OpenAPI.PathItem.Endpoint) -> HttpClientMethod in
            let operation: OpenAPI.Operation = endpoint.operation
            let methodName: String = operation.operationId ?? "\(endpoint.method.rawValue.lowercased())UnknownEntity"
            var arguments: [Argument] = []
            var contentType: OpenAPI.ContentType = .json

            if let requestBody = operation.requestBody {
                switch requestBody {
                    case .a(let reference): // Internal object
                        switch reference {
                            case .external:
                                fatalError("Not implemented yet")
                            case .internal:
                                fatalError("Not implemented yet")
                        }
                    case .b(let request): // Build new struct
                        for (key, value) in request.content where key != .xml {

                            if key != .any {
                                contentType = key
                            }

                            guard let schema = value.schema else { continue }

                            switch schema {
                                case .a(let innerJSONReference):
                                    let schema: ObjectSchema = schemas.first(where: { $0.name == innerJSONReference.name })!
                                    arguments.append(Argument(name: "\(schema.name.lowercased())", type: schema.name))
                                case .b(let schema):
                                    switch schema {
                                        case let .object(format, context):
                                            let schema: ObjectSchema = ObjectSchema(
                                                name: "\(methodName.capitalizeCamelCase())Input",
                                                format: format,
                                                context: context
                                            )
                                            arguments.append(Argument(name: "input", type: schema.name))
                                            customRequestBodies.insert(schema)
                                        case let .array(_, context):
                                            if let items = context.items {
                                                let dataFormat = DataFormat.generateDataFormat(from: items, objectName: "", propertyName: "")
                                                arguments.append(
                                                    Argument(name: "\(dataFormat.stringValue.lowercased())s", type: "[\(dataFormat.stringValue)]")
                                                )
                                            }
                                        default:
                                            os_log("Mapping methods failed", log: OSLog.endpointLogger, type: .error)
                                            fatalError("Not handled: \(value)")
                                }
                            }
                        }
                }
            }

            func addCompletionHandler(with returnValue: String, into arguments: inout [Argument]) {
                arguments.append(Argument(name: "completionHandler", type: "Result<\(returnValue), AFError>"))
            }

            if let response = operation.responses.first(where: { $0.key.rawValue == "200" }) {

                switch response.value {
                    case .a(let reference):
                        print(reference.name!)
                    case .b(let innerResponse):
                        for (key, value) in innerResponse.content where key != .xml {
                            guard let schema = value.schema else { continue }
                            switch schema {
                                case .a(let innerJSONReference):
                                    let schema: ObjectSchema = schemas.first(where: { $0.name == innerJSONReference.name })!
                                    addCompletionHandler(with: schema.name, into: &arguments)
                                case .b(let schema ):
                                    switch schema {
                                        case .object:
                                            addCompletionHandler(with: "Any", into: &arguments)
                                        case let .array(_, context):
                                            if let items = context.items {
                                                let dataFormat = DataFormat.generateDataFormat(from: items, objectName: "", propertyName: "")
                                                addCompletionHandler(with: "[\(dataFormat.stringValue)]", into: &arguments)
                                            }
                                        case .string:
                                            addCompletionHandler(with: "String", into: &arguments)
                                        default:
                                            fatalError("Not handled: \(value)")
                                    }
                            }
                        }
                }
            } else {
                addCompletionHandler(with: "Void", into: &arguments)
            }

            let method = HttpClientMethod(name: methodName, arguments: arguments.uniqued, contentType: contentType)
            return method
        }
        self.inputSchemas = customRequestBodies.sorted(by: { $0.name < $1.name })
    }

    public let path: String
    public let item: OpenAPI.PathItem
    public let methods: [HttpClientMethod]
    public let inputSchemas: [ObjectSchema]
}

public struct HttpClientMethod {

    public let name: String

    public let arguments: [Argument]

    public let contentType: OpenAPI.ContentType

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

extension Sequence where Element: Hashable {

    var uniqued: [Element] {
        var seen: Set<Element> = []
        return self.filter({ (element: Element) -> Bool in
            switch seen.contains(element) {
                case true:
                    return false

                case false:
                    seen.insert(element)
                    return true
            }
        })
    }
}
