//
//  File.swift
//
//
//  Created by vlsolome on 4/13/22.
//

import AOSEmulator
import Foundation

extension AOSEmulator {
    func open(link: URL) {
        commander.run(command: AOSOpenLinkCommand(url: link))
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}
