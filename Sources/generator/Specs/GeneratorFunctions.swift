//
//  GeneratorFunctions.swift
//
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 28.04.20.
//

import CodeBuilder
import Foundation
import OpenAPIKit

/**
 Generates a File that contains all the schemas of the OpenAPI document.
 - parameters:
    - fileName: The name of the file to be generated
    - schemas : The schemas to be decomposed as Swift models
    - indent  : The indent level used to format the Swift code to be generated
 - returns:
    A File object that represents a Swift file containing the JSONSchemas defined in the OpenAPI document as Swift models
 */
func generateModels(fileName: String = "GeneratedModels", schemas: OpenAPI.ComponentDictionary<JSONSchema>, indent: String) -> ([ObjectSchema], File) {
    let objects: [ObjectSchema] = schemas
        .compactMap { (schemaName: OpenAPI.ComponentKey, schema: JSONSchema) -> ObjectSchema? in
            guard case let .object(format, context) = schema else { return nil }
            return ObjectSchema(name: schemaName.rawValue, format: format, context: context)
        }

    let file: File = fileSpec(fileName: fileName, indent: indent) {
        ForEach(objects) { modelSpec(with: $0) }
    }

    return (objects, file)
}

func generateHttpClient(fileName: String = "GeneratedClient", paths: OpenAPI.PathItem.Map, schemas: [ObjectSchema], indent: String) -> File {
    paths
        .lazy
        .compactMap { (path: OpenAPI.Path, item: OpenAPI.PathItem) -> Void in
            for endpoint in item.endpoints {
                endpointSpec(with: path, item: item, schemas: schemas)
            }
        }
        .forEach { $0 }

    fatalError("Not implemented yet")
}
