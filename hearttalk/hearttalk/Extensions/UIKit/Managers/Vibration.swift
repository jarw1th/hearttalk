//
//  Vibration.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 24.01.2025.
//

import UIKit
import CoreHaptics

final class HapticManager {
    
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    
    init() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Ошибка инициализации движка Core Haptics: \(error)")
        }
    }

    func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func triggerContinuousVibration(duration: TimeInterval = 2.0, intensity: Float = 1.0) {
        guard let engine = engine, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: duration)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Ошибка воспроизведения вибрации: \(error)")
        }
    }
    
}
