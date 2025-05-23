//
//  WebContentExtractor.swift
//  App
//
//  Created by Lev on 16.03.25.
//

import Foundation
import SwiftSoup
import NaturalLanguage

enum ExtractorError: Error {
    case invalidResponse
    case invalidData
    case unsuportedLanguage
}

protocol ContentExtractor {
    func extractContent(from url: URL) async throws -> ExtractedContent
}

struct WebExtractor: ContentExtractor {
    func extractContent(from url: URL) async throws -> ExtractedContent {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }
        
        // Use a full-document parser if possible; otherwise, fall back to parsing as a body fragment.
        let doc: Document
        if htmlString.lowercased().contains("<html") {
            doc = try SwiftSoup.parse(htmlString)
        } else {
            doc = try SwiftSoup.parseBodyFragment(htmlString)
        }
        
        // Remove unwanted elements that might add extraneous text.
        try doc.select("script, style, nav, footer, header, aside").remove()
        
        // For many pages a direct extraction of all text is more reliable:
        let textContent = try doc.text()
        let cleaned = cleanText(textContent)
        let language = try cleaned.language()
        
        return ExtractedContent(text: cleaned, langauge: language ?? .english)
    }
    
    private func cleanText(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

struct ExtractedContent {
    let title: String = ""
    let text: String
    let langauge: Voice.Language
}
