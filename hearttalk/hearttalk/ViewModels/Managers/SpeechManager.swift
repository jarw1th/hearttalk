//
//  SpeechManager.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 06.02.2025.
//

import AVFoundation

class SpeechManager {
    
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()

    func speak(text: String, shouldStartNew: Bool = true) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            if !shouldStartNew {
                return
            }
        }

        let currentLocale = NSLocale.current
        let languageCode = currentLocale.languageCode ?? "en"
        let languageName = currentLocale.localizedString(forLanguageCode: languageCode) ?? "en-US"

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageName)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        synthesizer.speak(utterance)
    }
    
}
