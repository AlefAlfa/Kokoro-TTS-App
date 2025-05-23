//
//  Voice.swift
//  App
//
//  Created by Lev on 22.03.25.
//

import Foundation
import SwiftUI

enum Voice: String, CaseIterable, Identifiable {
    case alloy, aoede, bella, heart, jessica, kore, nicole, nova, river, sarah, sky
    case adam, echo, tom, fenrir, liam, michael, onyx, puck, santa
    case alice, emma, isabella, lily, daniel, fable, george, lewis
    case xiaobei, xiaoni, xiaoxiao, xiaoyi, yunjian, yunxi, yunxia, yunyang

    var id: Int {
        properties.id
    }
    
    var language: Language {
        properties.language
    }
    
    enum Gender: String {
        case male, female
    }
    
    enum Language: String {
        case english, chinese
        
        var duration: Double {
            switch self {
            case .english:
                Constants.Duration.english
            case .chinese:
                Constants.Duration.chinese
            }
        }
    }
    
    private var properties: (id: Int, language: Language) {
        switch self {
        case .alloy:
            return (0, .english)
        case .aoede:
            return (1, .english)
        case .bella:
            return (2, .english)
        case .heart:
            return (3, .english)
        case .jessica:
            return (4, .english)
        case .kore:
            return (5, .english)
        case .nicole:
            return (6, .english)
        case .nova:
            return (7, .english)
        case .river:
            return (8, .english)
        case .sarah:
            return (9, .english)
        case .sky:
            return (10, .english)
        case .adam:
            return (11, .english)
        case .echo:
            return (12, .english)
        case .tom:
            return (13, .english)
        case .fenrir:
            return (14, .english)
        case .liam:
            return (15, .english)
        case .michael:
            return (16, .english)
        case .onyx:
            return (17, .english)
        case .puck:
            return (18, .english)
        case .santa:
            return (19, .english)
        case .alice:
            return (20, .english)
        case .emma:
            return (21, .english)
        case .isabella:
            return (22, .english)
        case .lily:
            return (23, .english)
        case .daniel:
            return (24, .english)
        case .fable:
            return (25, .english)
        case .george:
            return (26, .english)
        case .lewis:
            return (27, .english)
        case .xiaobei:
            return (45, .chinese)
        case .xiaoni:
            return (46, .chinese)
        case .xiaoxiao:
            return (47, .chinese)
        case .xiaoyi:
            return (48, .chinese)
        case .yunjian:
            return (49, .chinese)
        case .yunxi:
            return (50, .chinese)
        case .yunxia:
            return (51, .chinese)
        case .yunyang:
            return (52, .chinese)
        }
    }
}

struct VoiceConfig: Hashable {
    var english: Voice
    var chinese: Voice
    
    init(english: Voice, chinese: Voice) {
        precondition(
            english.language == .english && chinese.language == .chinese
        )
        self.english = english
        self.chinese = chinese
    }
    
    func speaking(_ language: Voice.Language) -> Voice {
        switch language {
        case .english:
            return english
        case .chinese:
            return chinese
        }
    }
}
