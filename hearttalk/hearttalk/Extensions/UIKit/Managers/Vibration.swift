//
//  Vibration.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 24.01.2025.
//

import UIKit

final class HapticManager {
    
    static let shared = HapticManager()

    func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
}
