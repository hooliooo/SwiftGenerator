//
//  DataFormat.swift
//
//  Copyright (c) Julio Miguel Alorro 2020
//  MIT license, see LICENSE file for details
//  Created by Julio Miguel Alorro on 1.05.20.
//

import Foundation

/**
 A DataFormat decomposes information from a JSONSchema into a string representation usable for CodeBuilder
 */
public enum DataFormat {
    /**
     An array type with the associated value as the string representation of the element type
     */
    case array(String)

    /**
     An enum type with the object's name as a the parentName, the name of the enum, the data type for the enum, and the acceptable values for that enum
     */
    case `enum`(parentName: String, enum: AnyEnum)

    /**
     An object type.
     */
    case object(String)

    /**
     The string representation of the cases in a format suitable for CodeBuilder
     */
    public var stringValue: String {
        switch self {
            case .array(let type):
                return "[\(type)]"
            case let .enum(parentName, `enum`):
                return "\(parentName).\(`enum`.name)"
            case .object(let type):
                return type
        }
    }
}
