
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
    
    case whatis, share, review, terms, privacy, contact, clear
    
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
        case .clear:
            return "trash"
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
    
}

enum PDFType {
    
    case terms, privacy
    
    func url() -> URL? {
        switch self {
        case .terms:
            return Bundle.main.url(forResource: "TermsOfUse", withExtension: "pdf")
        case .privacy:
            return Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "pdf")
        }
    }
    
}

enum OnlineScreenType {
    
    case create, join
    
    func header() -> String {
        switch self {
        case .create:
            return "Create room"
        case .join:
            return "Join room"
        }
    }
    
}
