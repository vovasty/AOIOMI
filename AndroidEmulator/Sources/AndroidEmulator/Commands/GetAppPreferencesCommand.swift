//
//  File.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation
import SWXMLHash

private func getTempFile() -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                    isDirectory: true)

    let temporaryFilename = ProcessInfo().globallyUniqueString

    return temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
}

struct GetAppPreferencesCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?
    private let tmpFilePath = getTempFile()

    init(preferencesPath: String) {
        parameters = ["get_file", preferencesPath, tmpFilePath.path]
    }

    func parse(stdout _: [String]) throws -> XMLIndexer {
        let data = try Data(contentsOf: tmpFilePath)
        try FileManager.default.removeItem(at: tmpFilePath)
        let xml = SWXMLHash.config {
            config in
            config.shouldProcessLazily = true
        }.parse(data)
        return xml
    }
}
