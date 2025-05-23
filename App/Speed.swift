//
//  Speed.swift
//  App
//
//  Created by Lev on 22.03.25.
//

import Foundation

enum Speed: String, CaseIterable, Identifiable {
    case slow
    case medium
    case fast
    
    var value: Float {
        switch self {
        case .slow:
            0.8
        case .medium:
            1.0
        case .fast:
            1.3
        }
    }
    
    var id: Self { self }
}
