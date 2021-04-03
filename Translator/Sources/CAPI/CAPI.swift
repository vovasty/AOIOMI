//
//  File.swift
//
//
//  Created by vlsolome on 1/22/21.
//

import Foundation
import Translator

private var translator: Translator?

enum TranslatorError: Error {
    case notInitialized
}

private func buf2str(_ buf: UnsafePointer<CChar>?) -> String? {
    guard let buf = buf else { return nil }
    return String(cString: buf)
}

private func buf2strs(_ buf: UnsafePointer<UnsafePointer<CChar>?>?) -> [String]? {
    guard var buf = buf else { return nil }
    var result = [String]()
    while let pointee = buf.pointee {
        let str = String(cString: pointee)
        result.append(str)
        buf = buf.advanced(by: 1)
    }

    return result
}

@_cdecl("create_translator")
public func createTranslator() -> Bool {
    do {
        var dictionaries = [Dictionary]()
        do {
            let macDict = try MacDictionary(name: "뉴에이스 영한사전 / 뉴에이스 한영사전")
            dictionaries.append(macDict)
        } catch {}

        let googleDict = GoogleDictionary(fromLanguage: "ko", toLanguage: "en")
        dictionaries.append(googleDict)
        translator = try Translator(dictionaries: dictionaries, skipKeys: Set<String>(["rMessage"])) { string -> Bool in
            for c in string {
                guard c.isASCII else { return true }
            }
            return false
        }
        return true
    } catch {
        print(error)
        return false
    }
}

@_cdecl("translate")
public func translate(json: UnsafePointer<CChar>?, path: UnsafePointer<UnsafePointer<CChar>?>?) -> UnsafePointer<CChar>? {
    guard let jsonString = buf2str(json) else { return json }
    let pathsString = buf2strs(path) ?? [""]

    do {
        guard let translator = translator else { throw TranslatorError.notInitialized }
        let result = try translator.translate(json: jsonString, path: pathsString)
        let count = result.utf8.count + 1
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: count)

        result.withCString { baseAddress in
            buf.initialize(from: baseAddress, count: count)
        }
        return UnsafePointer(buf)
    } catch {
        print(error)
        return json
    }
}
