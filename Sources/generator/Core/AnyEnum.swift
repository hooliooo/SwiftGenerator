//
//  AnyEnum.swift
//  
//
//  Created by Julio Miguel Alorro on 5/1/20.
//

import CodeBuilder
import Foundation

/**
 A representation of an enum from the OpenAPI Schema
 */
public struct AnyEnum {
    
    // Initializers
    /**
     Creates an AnyEnum representation of a JSONSchema of an enum
     - parameters:
        - access   : The access level of the enum
        - spec : The specifications of the enum
        - inheritingFrom: The inherited types of the enum
     */
    public init(access: Access, spec: Enum, inheritingFrom: [String]) {
        self.value = spec
        self.name = spec.name
        self.code = enumSpec(access: access, enumSpec: spec, inheritingFrom: inheritingFrom, { Code.none })
    }
    
    /**
     Creates an AnyEnum representation of a JSONSchema of an enum with raw values
     - parameters:
        - access   : The access level of the raw value enum
        - spec : The specifications of the raw value enum
        - inheritingFrom: The inherited types of the raw value enum
     */
    public init<T>(access: Access, spec: RawValueEnum<T>, inheritingFrom: [String]) {
        self.value = spec
        self.name = spec.name
        self.code = rawValueEnumSpec(access: access, enumSpec: spec, inheritingFrom: inheritingFrom, { Code.none })
    }
    
    /**
     The specifications of the enum such as name and cases (if any)
     */
    public let value: Any
    
    /**
     The name of the enum
     */
    public let name: String
    
    /**
     The CodeRepresentable of the enum
     */
    public let code: CodeRepresentable

}
