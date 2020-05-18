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

func endpointSpec(with method: HttpClientMethod) -> CodeRepresentable {
    functionSpec(
        method.name,
        access: Access.public,
        isStatic: false,
        throwsError: false,
        genericSignature: nil,
        arguments: method.arguments,
        returnValue: nil,
        {
            Code.none
        }
    )
}
