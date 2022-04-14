//
//  IOSSimulator.swift
//
//
//  Created by vlsolome on 4/13/22.
//

import Foundation
import IOSSimulator

extension IOSSimulator {
    func open(link: URL) {
        commander.run(command: IOSOpenLinkCommand(simulatorName: simulatorName, url: link))
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}
