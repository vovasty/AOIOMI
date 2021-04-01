//
//  File.swift
//
//
//  Created by vlsolome on 2/5/21.
//

import Foundation

public struct TranslateAddon: Addon {
    public struct Definition: Codable {
        public let url: String
        public let paths: [String]

        public init(url: String, paths: [String]) {
            self.url = url
            self.paths = paths
        }
    }

    public let id: String = "translateAddon"
    public let constructor: String
    public let importString = "from translateaddon import TranslateAddon"

    public init(definitions: [Definition]) {
        let definitionsString = definitions
            .map {
                let pathsString = $0.paths.map { "\"\($0)\"" }.joined(separator: ", ")
                return "\"\($0.url)\": [\(pathsString)]"
            }
            .joined(separator: ", ")

        constructor =
            """
            TranslateAddon({\(definitionsString)})
            """
    }
}
