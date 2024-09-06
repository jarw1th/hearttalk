
import SwiftUI
import RealmSwift
import StoreKit
import AVFoundation

@MainActor
final class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    private var realmManager: RealmManager = RealmManager()
    private var networkManager: NetworkManager = NetworkManager()
    
    @Published var myCardTypes: [CardType] = []
    @Published var cardTypes: [CardType] = []
    @Published var cards: [Card] = []
    @Published var cardIndex: Int = 0 {
        didSet {
            updateCardFavoriteStatus()
        }
    }
    @Published var isCardFavorite: Bool = false
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
    var isShowTip: Bool {
        get {
            if UserDefaults.standard.object(forKey: "isShowTip") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "isShowTip")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isShowTip")
        }
    }
    
    private let defaultCardTypes = ["Default mode", "Couples", "Family", "Favorites", "Created"]
    private let hasImportedDataKey = "hasImportedData"
    private var createdPackId: String?
    
    init() {
        if !UserDefaults.standard.bool(forKey: hasImportedDataKey) {
            parseCardTypesFromFile()
            UserDefaults.standard.set(true, forKey: hasImportedDataKey)
        }
        fetchAllCardTypes()
    }
    
    private func parseCardTypesFromFile() {
        let cardTypesWithFileNames = [
            ("Default mode", "default"),
            ("Couples", "couples"),
            ("Family", "family"),
            ("Favorites", "favorites")
        ]
        
        for (cardTypeName, fileName) in cardTypesWithFileNames {
            addCardType(withName: cardTypeName, fromFile: fileName)
        }
        addCardType(withName: "Created", fromFile: "my", save: true)
    }
    
    private func addCardType(withName name: String, fromFile fileName: String, save: Bool = false) {
        do {
            if let fileContents = try? readTextFile(fileName: fileName) {
                let lines = fileContents.components(separatedBy: .newlines)
                
                guard let colorLine = lines.first(where: { $0.starts(with: "Color:") }) else {
                    print("Error: No color found in file \(fileName)")
                    return
                }
                
                let colorValue = colorLine.replacingOccurrences(of: "Color:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                let cardType = CardType(id: UUID().uuidString, name: name)
                cardType.color = colorValue
                if save {
                    createdPackId = cardType.id
                }
                
                let questions = lines.dropFirst().filter { !$0.isEmpty && !$0.starts(with: "Color:") }
                
                for question in questions {
                    let card = Card(id: UUID().uuidString, question: question)
                    cardType.cards.append(card)
                }
                
                realmManager.add(cardType)
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    private func readTextFile(fileName: String) throws -> String {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            return try String(contentsOfFile: filePath, encoding: .utf8)
        } else {
            throw NSError(domain: "FileNotFound", code: 404, userInfo: nil)
        }
    }
    
    func fetchAllCardTypes() {
        self.cardTypes = []
        self.myCardTypes = []
        let cardTypesResults = self.realmManager.getAllCardTypes()
        
        self.cardTypes = Array(cardTypesResults)
        self.myCardTypes = Array(cardTypesResults).filter { !defaultCardTypes.contains($0.name) }
    }
    
    func fetchCards(forCardTypeId cardTypeId: String) {
        if let cardsList = self.realmManager.getCards(forCardTypeId: cardTypeId) {
            self.cards = Array(cardsList)
        } else {
            self.cards = []
        }
    }
    
    func createPack(name: String, color: String, cardQuestions: [String]) {
        do {
            let cardType = CardType()
            cardType.id = UUID().uuidString
            cardType.name = name
            cardType.color = color
            
            let cardObjects = cardQuestions.map { question -> Card in
                let card = Card()
                card.id = UUID().uuidString
                card.question = question
                return card
            }
            
            self.realmManager.add(cardType)
            cardType.cards.append(objectsIn: cardObjects)
            
            DispatchQueue.main.async {
                self.fetchAllCardTypes() 
            }
        } catch {
            print("Error creating CardType: \(error)")
        }
    }
    
    func createCard(question: String) {
        do {
            if let createdPackId = createdPackId,
               let createdPack = self.realmManager.getCardType(forId: createdPackId) {
                let newCard = Card()
                newCard.id = UUID().uuidString
                newCard.question = question
                
                self.realmManager.update {
                    createdPack.cards.append(newCard)
                }
                
                self.fetchCards(forCardTypeId: createdPackId)
            }
        } catch {
            print("Error creating Card: \(error)")
        }
    }
    
    func createCardImage(_ question: String) -> UIImage? {
        let hostingController = UIHostingController(rootView: CardForShare(question: question))
        let view = hostingController.view
        let targetSize = CGSize(width: 300, height: 600) 
        
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
    }
    
    func shareApp() -> String {
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "MyApp"
        let appURL = "https://apps.apple.com/app/idYOUR_APP_ID"
        let shareText = "Check out \(appName) - \(appURL)"
        return shareText
    }
    
    func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    func addCardToFavorites(_ card: Card) {
        guard let favoritesCardType = realmManager.getCardType(forName: "Favorites") else {
            print("Error: 'Favorites' card type not found.")
            return
        }
        
        if let existingCard = favoritesCardType.cards.first(where: { $0.id == card.id }) {
            realmManager.update {
                if let index = favoritesCardType.cards.firstIndex(of: existingCard) {
                    favoritesCardType.cards.remove(at: index)
                }
            }
            print("Card removed from Favorites.")
        } else {
            realmManager.update {
                favoritesCardType.cards.append(card)
            }
            print("Card added to Favorites.")
        }
        
        updateCardFavoriteStatus()
    }
    
    func addCard(_ card: Card, to cardType: CardType) {
        if let existingCard = cardType.cards.first(where: { $0.id == card.id }) {
            realmManager.update {
                if let index = cardType.cards.firstIndex(of: existingCard) {
                    cardType.cards.remove(at: index)
                }
            }
            print("Card removed from Favorites.")
        } else {
            realmManager.update {
                cardType.cards.append(card)
            }
            print("Card added to Favorites.")
        }
        
        updateCardFavoriteStatus()
    }
    
    func updateCardFavoriteStatus() {
        guard let favoritesCardType = realmManager.getCardType(forName: "Favorites") else {
            print("Error: 'Favorites' card type not found.")
            isCardFavorite = false
            return
        }
        
        isCardFavorite = favoritesCardType.cards.contains { $0.id == cards[cardIndex].id }
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
    
    func createQuestionAI(prompt: String) async -> String {
        do {
            return try await networkManager.createQuestion(prompt: prompt)
        } catch {
            return ""
        }
    }
    
    func clearData() {
        realmManager.deleteAll()
        parseCardTypesFromFile()
        fetchAllCardTypes()
        cardIndex = 0
        cards = []
        isCardFavorite = false
    }
    
}

