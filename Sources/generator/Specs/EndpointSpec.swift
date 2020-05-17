//
//  EndpointSpec.swift
//
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 17.05.20.
//

import CodeBuilder
import Foundation
import OpenAPIKit

func endpointSpec(with path: OpenAPI.Path, item: OpenAPI.PathItem, schemas: [ObjectSchema]) -> (requestStructs: [CodeRepresentable], method: CodeRepresentable) {
    let schema: EndpointSchema = EndpointSchema(path: path, item: item, schemas: schemas)
//    let methodName: String = endpoint.operation.operationId ?? "\(endpoint.verb.rawValue.lowercased())UnknownEntity"
//    let parameters = endpoint.operation.parameters
//        .map { (either: Either<JSONReference<OpenAPI.PathItem.Parameter>, OpenAPI.PathItem.Parameter>) -> String in
//            switch either {
//                case .a(let reference):
//                    switch reference {
//                        case .external(let url):
//                            return url.absoluteString
//                        case .internal(let innerReference):
//                            switch innerReference {
//                                case .component(let name):
//                                    return name
//                                case .path(let innerJSONReference):
//                                    return innerJSONReference.description
//                            }
//                    }
//                case .b(let parameter):
//                    return parameter.name
//            }
//        }
//    if let requestBody = endpoint.operation.requestBody {
//        switch requestBody {
//            case .a(let reference):
//                switch reference {
//                    case .external(let url):
//                        print(url)
//                    case .internal(let innerReference):
//                        switch innerReference {
//                            case .component(let name):
//                                print(name)
//                            case .path(let innerJSONReference):
//                                print(innerJSONReference.description)
//                        }
//                }
//            case .b(let reference):
//                guard let (key, value) = reference.content.first(where: { (key, value) in key == .json }) else { fatalError() }
//                switch value.schema {
//                    case .a(let innerJSONReference):
//                        print(innerJSONReference.name)
//                    case .b(let schema):
//                        print(schema.jsonTypeFormat?.jsonType.rawValue)
//                }
//        }
//    }

    return ([], SingleLineFragment(""))
}
