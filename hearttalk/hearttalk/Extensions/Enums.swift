
import Foundation

enum TabType: String, CaseIterable, Identifiable {
    
    case home
    case search
    case add
    case profile
    case settings
    
    static let offlineAllCases = [TabType.home, TabType.add, TabType.settings]
    
    var id: String {
        return self.rawValue
    }
    
    var text: String {
        switch self {
        case .home:
            return Localization.home
        case .search:
            return Localization.online
        case .add:
            return ""
        case .profile:
            return ""
        case .settings:
            return Localization.settings
        }
    }
    
    var imageName: String {
        switch self {
        case .home:
            return "home"
        case .search:
            return "search"
        case .add:
            return "add"
        case .profile:
            return "profile"
        case .settings:
            return "settings"
        }
    }
    
}

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
            Localization.passwordAlert
        case .email:
            Localization.emailAlert
        case .server:
            Localization.serverAlert
        case .successReset(let email):
            "\(Localization.successResetAlert) \(email)"
        case .wrongPassword(let email):
            "\(Localization.wrongPasswordAlert) \(email)"
        case .noEmail(let email):
            "\(Localization.noEmailAlert) \(email)"
        }
    }
    
}

enum ImportAlertType: Identifiable, Hashable {
    
    case packName
    case txt
    
    var id: String {
        switch self {
        case .packName:
            "packName"
        case .txt:
            "txt"
        }
    }
    
    var text: String {
        switch self {
        case .packName:
            Localization.packNameAlert
        case .txt:
            Localization.txtAlertMessage
        }
    }
    
}

enum GenerateAlertType: Identifiable, Hashable {
    
    case packName
    case cardNumber
    case propmt
    
    var id: String {
        switch self {
        case .packName:
            "packName"
        case .cardNumber:
            "cardNumber"
        case .propmt:
            "propmt"
        }
    }
    
    var text: String {
        switch self {
        case .packName:
            Localization.packNameAlert
        case .cardNumber:
            Localization.cardNumberAlert
        case .propmt:
            Localization.promptAlert
        }
    }
    
}

enum SettingsActionSheetType: Identifiable, Hashable {
    
    case language
    case contacts

    var id: String {
        switch self {
        case .language:
            "language"
        case .contacts:
            "contacts"
        }
    }
    
    var title: String {
        switch self {
        case .language:
            Localization.languageAlertTitle
        case .contacts:
            Localization.contactsAlertTitle
        }
    }

    var text: String {
        switch self {
        case .language:
            Localization.languageAlertMessage
        case .contacts:
            Localization.contactsAlertMessage
        }
    }

}

enum OnlineSectionType: String, Identifiable {
    
    case cards
    case packs
    case profiles

    var id: String {
        self.rawValue
    }
    
    var title: String {
        switch self {
        case .cards:
            Localization.onlineCards
        case .packs:
            Localization.onlinePacks
        case .profiles:
            "Profiles"
        }
    }

}
