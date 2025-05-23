//
//  String.swift
//  App
//
//  Created by Lev on 15.03.25.
//

import Foundation
import NaturalLanguage

extension String {
    func preProcessed() -> String {
        var text = self
        text = trimmed(text)
        text = straightQuotes(text)
        text = withoutHyphens(text)
        return text
    }
    
    func language() throws -> Voice.Language? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        let language = recognizer.dominantLanguage
        switch language {
        case .english:
            return .english
        case .simplifiedChinese:
            return .chinese
        case .traditionalChinese:
            return .chinese
        default:
            throw ExtractorError.unsuportedLanguage
        }
    }
    
    func wordCount() -> Int {
        var count = 0
        self.enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .byWords) { (substring, _, _, _) in
            if let word = substring, !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                count += 1
            }
        }
        return count
    }
    
    func paragraphCount() -> Int {
        let paragraphs = self.components(separatedBy: CharacterSet.newlines)
        let nonEmptyParagraphs = paragraphs.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return nonEmptyParagraphs.count
    }
}

private func trimmed(_ text: String) -> String {
    text
        .trimmingCharacters(in: .whitespacesAndNewlines)
//        .replacingOccurrences(of: "\n", with: " ")
}

private func straightQuotes(_ text: String) -> String {
    text
        .replacingOccurrences(of: "’", with: "'")
        .replacingOccurrences(of: "‘", with: "'")
        .replacingOccurrences(of: "“", with: "\"")
        .replacingOccurrences(of: "”", with: "\"")
}

private func withoutHyphens(_ text: String) -> String {
    text.replacingOccurrences(of: "-", with: " ")
        .replacingOccurrences(of: ",", with: ";")
}
