
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
    
    case whatis, share, review, terms, privacy, contact
    
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
        }
    }
    
}
