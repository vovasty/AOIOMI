//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import Foundation

extension JSONDecoder {
    enum DecodeError: Error {
        case noFile
    }

    func decode<Type: Decodable>(fileName: String, type: Type.Type) throws -> Type {
        guard let jsonURL = Bundle.module.url(forResource: fileName, withExtension: nil) else {
            throw DecodeError.noFile
        }

        let data = try Data(contentsOf: jsonURL)
        return try decode(type, from: data)
    }
}

extension JSONEncoder {
    enum EncodeError: Error {
        case badData
    }

    func toString<Type: Encodable>(_ object: Type) throws -> String {
        let data = try encode(object)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodeError.badData
        }

        return string
    }
}
