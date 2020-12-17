//
//  File.swift
//
//
//  Created by vlsolome on 12/16/20.
//

import Combine
import Foundation

func getTempFile() -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                    isDirectory: true)

    let temporaryFilename = ProcessInfo().globallyUniqueString

    return temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
}

extension Collection where Element: Publisher {
    func serialize() -> AnyPublisher<Element.Output, Element.Failure>? {
        guard let start = first else { return nil }
        return dropFirst().reduce(start.eraseToAnyPublisher()) {
            $0.append($1).eraseToAnyPublisher()
        }
    }
}
