
import Foundation

enum QuestionMode {
    
    case cards, list
    
    func imageName() -> String {
        switch self {
        case .cards:
            return "list"
        case .list:
            return "cards"
        }
    }
    
    mutating func toggle() {
        switch self {
        case .cards:
            self = .list
        case .list:
            self = .cards
        }
    }
    
}

enum AboutAppType: CaseIterable {
    
    case whatis, share, review, terms, privacy, contact, settings
    
    func imageName() -> String {
        switch self {
        case .whatis:
            return "whatIs"
        case .share:
            return "share"
        case .review:
            return "review"
        case .terms:
            return "terms"
        case .privacy:
            return "privacy"
        case .contact:
            return "contact"
        case .settings:
            return "settings"
        }
    }
    
    func text() -> String {
        switch self {
        case .whatis:
            return Localization.whatIs
        case .share:
            return Localization.share
        case .review:
            return Localization.review
        case .terms:
            return Localization.terms
        case .privacy:
            return Localization.privacy
        case .contact:
            return Localization.contact
        case .settings:
            return Localization.settings
        }
    }
    
    func isSpecial() -> Bool {
        switch self {
        case .settings:
            return true
        default:
            return false
        }
    }
    
}

enum SettingsType: CaseIterable {
    
    case vibrations, sounds, dailyCard, theme, language, clear
    
    func imageName() -> String {
        switch self {
        case .vibrations:
            return ""
        case .sounds:
            return ""
        case .dailyCard:
            return ""
        case .theme:
            return ""
        case .language:
            return "language"
        case .clear:
            return "trash"
        }
    }
    
    func text() -> String {
        switch self {
        case .vibrations:
            return Localization.vibrations
        case .sounds:
            return Localization.sounds
        case .dailyCard:
            return Localization.dailyCard
        case .theme:
            return Localization.darkMode
        case .language:
            let locale = Locale.current
            if let language = locale.localizedString(forLanguageCode: UserDefaultsManager.shared.appleLanguage) {
                return language.capitalized
            }
            return "English"
        case .clear:
            return Localization.clear
        }
    }
    
    func isSpecial() -> Bool {
        switch self {
        case .clear:
            return true
        default:
            return false
        }
    }
    
}

enum CreateScreenType {
    
    case card, pack
    
    func header() -> String {
        switch self {
        case .card:
            return Localization.createCard
        case .pack:
            return Localization.createPack
        }
    }
    
    func placeholder() -> String {
        switch self {
        case .card:
            return Localization.question
        case .pack:
            return Localization.name
        }
    }
    
    func alert() -> String {
        switch self {
        case .card:
            return Localization.alertCard
        case .pack:
            return Localization.alertPack
        }
    }
    
}

enum PDFType {
    
    case terms, privacy
    
    func url() -> URL? {
        switch self {
        case .terms:
            if UserDefaultsManager.shared.appleLanguage == "ru" {
                return Bundle.main.url(forResource: "TermsOfUse_ru", withExtension: "pdf")
            } else {
                return Bundle.main.url(forResource: "TermsOfUse_en", withExtension: "pdf")
            }
        case .privacy:
            if UserDefaultsManager.shared.appleLanguage == "ru" {
                return Bundle.main.url(forResource: "PrivacyPolicy_ru", withExtension: "pdf")
            } else {
                return Bundle.main.url(forResource: "PrivacyPolicy_en", withExtension: "pdf")
            }
        }
    }
    
}

enum QuickAction: Hashable {
    
    case addCard, addPack
    
}

enum OnlineSearchType: String, Identifiable, CaseIterable {
    
    case cards
    case accounts
    case packs
    
    var id: String {
        self.rawValue
    }
    
    var value: String {
        switch self {
        case .cards:
            "Cards"
        case .accounts:
            "Accounts"
        case .packs:
            "Packs"
        }
    }
    
}

enum OnlineAlertType: Identifiable, Hashable {
    
    case password
    case email
    case server
    case successReset(String)
    case wrongPassword(String)
    case noEmail(String)
    
    var id: String {
        switch self {
        case .password:
            "password"
        case .email:
            "email"
        case .server:
            "server"
        case .successReset(_):
            "successReset"
        case .wrongPassword(_):
            "wrongPassword"
        case .noEmail(_):
            "noEmail"
        }
    }
    
    var text: String {
        switch self {
        case .password:
            "Password should have: special symbols, numbers, length is more than 8."
        case .email:
            "Wrong email"
        case .server:
            "Server error"
        case .successReset(let email):
            "We sent reset link to \(email)"
        case .wrongPassword(let email):
            "Wrong password for \(email)"
        case .noEmail(let email):
            "We do not have such email \(email)"
        }
    }
    
}
