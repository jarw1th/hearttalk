//
//  OpenFunctions.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 01.02.2025.
//

import SwiftUI
import Speech
import FirebaseAuth
import FirebaseFirestore

func createCardImage(_ question: String) -> IdentifiableImage? {
    let hostingController = UIHostingController(rootView: CardForShare(question: question))
    let view = hostingController.view
    let targetSize = CGSize(width: 300, height: 600)
    
    view?.bounds = CGRect(origin: .zero, size: targetSize)
    view?.backgroundColor = .clear
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let identifiableImage = IdentifiableImage(image: renderer.image { _ in
        view?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
    })
    return identifiableImage
}

func speak(text: String) {
    let currentLocale = NSLocale.current
    let languageCode = currentLocale.languageCode ?? "en"
    let languageName = currentLocale.localizedString(forLanguageCode: languageCode) ?? "en-US"
    
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: languageName)
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate

    let synthesizer = AVSpeechSynthesizer()
    synthesizer.speak(utterance)
}

func setUserOnline() {
    guard let user = Auth.auth().currentUser else { return }

    let path = Firestore.firestore().collection("users").document(user.uid)
    
    path.updateData([
        "lastSeen": FieldValue.serverTimestamp()
    ]) { error in
        if let error = error {
            print("Error setting user online status: \(error.localizedDescription)")
        } else {
            print("User is now online")
        }
    }
}

func timeAgoSince(_ date: Date) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: Date())
    
    if let year = components.year, year > 0 {
        return "\(year) \(year == 1 ? Localization.year : year > 1 && year < 5 ? Localization.years : Localization.yearss) \(Localization.ago)"
    }
    if let month = components.month, month > 0 {
        return "\(month) \(month == 1 ? Localization.month : month > 1 && month < 5 ? Localization.months : Localization.monthss) \(Localization.ago)"
    }
    if let week = components.weekOfYear, week > 0 {
        return "\(week) \(week == 1 ? Localization.week : week > 1 && week < 5 ? Localization.weeks : Localization.weekss) \(Localization.ago)"
    }
    if let day = components.day, day > 0 {
        return "\(day) \(day == 1 ? Localization.day : day > 1 && day < 5 ? Localization.days : Localization.dayss) \(Localization.ago)"
    }
    if let hour = components.hour, hour > 0 {
        return "\(hour) \(hour == 1 ? Localization.hour : hour > 1 && hour < 5 ? Localization.hours : Localization.hourss) \(Localization.ago)"
    }
    if let minute = components.minute, minute > 0 {
        return "\(minute) \(minute == 1 ? Localization.minute : minute > 1 && minute < 5 ? Localization.minutes : Localization.minutess) \(Localization.ago)"
    }
    
    return Localization.justNow
}
