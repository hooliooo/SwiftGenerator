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
func generateModels(fileName: String, schemas: OpenAPI.ComponentDictionary<JSONSchema>, indent: String) -> File {
    let models: [CodeRepresentable] = schemas
        .compactMap { (schemaName: OpenAPI.ComponentKey, schema: JSONSchema) -> CodeRepresentable? in
            guard case let .object(format, context) = schema else { return nil }
            let objectSchema = ObjectSchema(name: schemaName.rawValue, format: format, context: context)
            return modelSpec(with: objectSchema)
        }

    return fileSpec(fileName: fileName, indent: indent) {
        ForEach(models) { $0 }
    }
}
