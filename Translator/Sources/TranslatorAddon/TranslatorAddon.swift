//
//  File.swift
//
//
//  Created by vlsolome on 2/5/21.
//

import Foundation
import MITMProxy

public struct TranslatorAddon: Addon {
    public struct Definition: Codable {
        public let url: String
        public let paths: [String]

        public init(url: String, paths: [String]) {
            self.url = url
            self.paths = paths
        }
    }

    public let id: String = "translatorAddon"
    public let constructor: String
    public let importString = "from translatoraddon import TranslatorAddon"
    public let sysPath: String?

    public init(definitions: [Definition]) {
        let definitionsString = definitions
            .map {
                let pathsString = $0.paths.map { "\"\($0)\"" }.joined(separator: ", ")
                return "\"\($0.url)\": [\(pathsString)]"
            }
            .joined(separator: ", ")

        constructor =
            """
            TranslatorAddon({\(definitionsString)})
            """
        sysPath = Bundle.module.url(forResource: "python", withExtension: "")?.path
    }
}
