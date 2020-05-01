//
//  AnyEnum.swift
//  
//
//  Created by Julio Miguel Alorro on 5/1/20.
//

import CodeBuilder
import Foundation


public struct AnyEnum {

    public init(access: Access, enum: Enum, inheritingFrom: [String]) {
        self.value = `enum`
        self.name = `enum`.name
        self.code = enumSpec(access: access, enumSpec: `enum`, inheritingFrom: inheritingFrom, { Code.fragments([]) })

    }

    public init<T>(access: Access, enum: RawValueEnum<T>, inheritingFrom: [String]) {
        self.value = `enum`
        self.name = `enum`.name
        self.code = rawValueEnumSpec(access: access, enumSpec: `enum`, inheritingFrom: inheritingFrom, { Code.fragments([]) })

    }

    public let value: Any
    public let name: String
    public let code: CodeRepresentable

}
