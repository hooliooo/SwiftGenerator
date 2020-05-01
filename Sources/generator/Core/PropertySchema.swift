//
//  PropertyDescription.swift
//
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 1.05.20.
//

import CodeBuilder
import Foundation

/**
 Holds information about a property of an ObjectSchema
 */
public struct PropertyDescription {

    /**
     Initializer
        - parameters:
            - documentation: The documentation describing the property
            - property     : CodeBuilder related metadata used to create a Swift code representations of the property

     */
    public init(documentation: Documentation, property: StoredProperty) {
        self.documentation = documentation
        self.property = property
    }

    /**
     The documentation describing the property
     */
    public let documentation: Documentation

    /**
     CodeBuilder related metadata used to create a Swift code representations of the property
     */
    public let property: StoredProperty

}
