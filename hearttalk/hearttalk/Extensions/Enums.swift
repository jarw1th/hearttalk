
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
            return "What is Heart Talk?"
        case .share:
            return "Share Heart Talk"
        case .review:
            return "Write a review"
        case .terms:
            return "Terms of Use"
        case .privacy:
            return "Privacy Policy"
        case .contact:
            return "Contact us"
        case .clear:
            return "Clear data"
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
            return "Create card"
        case .pack:
            return "Create pack"
        }
    }
    
    func placeholder() -> String {
        switch self {
        case .card:
            return "Question"
        case .pack:
            return "Name"
        }
    }
    
}
