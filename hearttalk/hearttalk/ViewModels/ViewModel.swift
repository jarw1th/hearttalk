
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
    @Published var cardPacks: [CardPack] = []
    @Published var cards: [Card] = []
    @Published var notes: [Note] = []
    @Published var cardIndex: Int = 0 {
        didSet {
            updateCardFavoriteStatus()
        }
    }
    @Published var noteIndex: Int = 0 
    @Published var isCardFavorite: Bool = false
    @Published var favoriteType: CardType?
    @Published var selectedSavingType: CardType?
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
    var isShowAgeAlert: Bool {
        get {
            if UserDefaults.standard.object(forKey: "isShowAgeAlert") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "isShowAgeAlert")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isShowAgeAlert")
        }
    }
    
    private let defaultCardTypes = [Localization.favorites, Localization.simple, Localization.family, Localization.taboo, Localization.sex, Localization.close, Localization.closer, Localization.closest]
    private let hasImportedDataKey = "hasImportedData"
    private var createdPackId: String?
    private var createdTypeId: String?
    
    init() {
        let userLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        if UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en" == userLanguage {
            if !UserDefaults.standard.bool(forKey: hasImportedDataKey) {
                parseCardTypesFromFile()
                UserDefaults.standard.set(true, forKey: hasImportedDataKey)
            }
            fetchAll()
        } else {
            clearData()
            UserDefaults.standard.set(userLanguage, forKey: "selectedLanguage")
        }
    }
    
    private func parseCardTypesFromFile() {
        let cardPacks = [Localization.defaultPack, Localization.couples, Localization.adult]
        let cardTypes = [[(Localization.simple, Localization.simpleDesc, "default_simple"), (Localization.family, Localization.familyDesc, "default_family")],
                         [(Localization.close, Localization.closeDesc, "couples_close"), (Localization.closer, Localization.closerDesc, "couples_closer"), (Localization.closest, Localization.closestDesc, "couples_closest")],
                         [(Localization.taboo, Localization.tabooDesc, "adult_taboo"), (Localization.sex, Localization.sexDesc, "adult_sex")]]
        
        for (index, cardPackName) in cardPacks.enumerated() {
           addCardPack(packName: cardPackName, cardTypes: cardTypes[index], isAdult: index == 2)
        }
        addCardPack(packName: Localization.favorites, cardTypes: [(Localization.favorites, "", "favorites")], isFavorites: true, isSpecial: true)
        addCardPack(packName: Localization.created, cardTypes: [(Localization.unsorted, Localization.unsortedDesc, "created")], save: true, isSpecial: true)
    }
    
    private func addCardPack(packName name: String, cardTypes: [(String, String, String)], save: Bool = false, isFavorites: Bool = false, isSpecial: Bool = false, isAdult: Bool = false) {
        let userLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        
        var cardPack = CardPack(id: UUID().uuidString, name: name)
        for (cardTypeName, description, baseFileName) in cardTypes {
            let fileName = "\(baseFileName)_\(userLanguage)"
            cardPack = addCardType(withPack: cardPack, withTypeName: cardTypeName, withText: description, fromFile: fileName, with: isSpecial ? baseFileName : "\(baseFileName)_en", save: save, isFavorites: isFavorites) ?? CardPack(id: UUID().uuidString, name: name)
        }
        cardPack.isAdult = isAdult
        
        realmManager.add(cardPack)
    }
    
    private func addCardType(withPack pack: CardPack, withTypeName typeName: String, withText description: String, fromFile fileName: String, with baseName: String, save: Bool = false, isFavorites: Bool = false) -> CardPack? {
        var fileContents: String = ""
        guard let baseFileContents = try? readTextFile(fileName: baseName) else {
            print("Error fetching file")
            return nil
        }
        if let langFileContents = try? readTextFile(fileName: fileName) {
            fileContents = langFileContents
        } else {
            fileContents = baseFileContents
        }
        
        let lines = fileContents.components(separatedBy: .newlines)
        
        guard let packColorLine = lines.first(where: { $0.starts(with: "Pack Color:") }) else {
            print("Error: No color found in file \(fileName)")
            return nil
        }
        guard let typeColorLine = lines.first(where: { $0.starts(with: "Type Color:") }) else {
            print("Error: No color found in file \(fileName)")
            return nil
        }
        
        let packColor = packColorLine.replacingOccurrences(of: "Pack Color:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        pack.color = packColor
        let typeColor = typeColorLine.replacingOccurrences(of: "Type Color:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cardType = CardType(id: UUID().uuidString, name: typeName, text: description)
        cardType.color = typeColor
        if isFavorites {
            favoriteType = cardType
        }
        if save {
            createdPackId = pack.id
            createdTypeId = cardType.id
        }
        
        let questions = lines.dropFirst().filter { !$0.isEmpty && !$0.starts(with: "Pack Color:") && !$0.starts(with: "Type Color:") }
        
        for question in questions {
            let card = Card(id: UUID().uuidString, question: question)
            cardType.cards.append(card)
        }
        
        pack.cardTypes.append(cardType)
        return pack
    }
    
    private func readTextFile(fileName: String) throws -> String {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            return try String(contentsOfFile: filePath, encoding: .utf8)
        } else {
            throw NSError(domain: "FileNotFound", code: 404, userInfo: nil)
        }
    }
    
    func fetchAll() {
        self.cardTypes = []
        self.myCardTypes = []
        self.favoriteType = nil
        let cardTypesResults = self.realmManager.getAllCardTypes()
        
        fetchAllCardPacks()
        self.cardTypes = Array(cardTypesResults)
        self.myCardTypes = Array(cardTypesResults).filter { !defaultCardTypes.contains($0.name) }
        self.favoriteType = cardTypes.filter({ $0.name == Localization.favorites }).first
        self.createdPackId = cardPacks.filter({ $0.name == Localization.created }).first?.id
        self.createdTypeId = cardTypes.filter({ $0.name == Localization.unsorted }).first?.id
        self.selectedSavingType = cardTypes.filter({ $0.name == Localization.unsorted }).first
    }
    
    func fetchAllCardPacks() {
        self.cardPacks = []
        let cardPacksResults = self.realmManager.getAllCardPacks()
        
        self.cardPacks = Array(cardPacksResults).filter { $0.name != Localization.favorites }
    }
    
    func fetchAllCardTypes(forCardPackId cardPackId: String) {
        if let cardTypesList = self.realmManager.getCardTypes(forCardPackId: cardPackId) {
            self.cardTypes = Array(cardTypesList)
            self.myCardTypes = Array(self.realmManager.getAllCardTypes()).filter { !defaultCardTypes.contains($0.name) }
        } else {
            self.cardTypes = []
        }
    }
    
    func fetchCards(forCardTypeId cardTypeId: String) {
        if let cardsList = self.realmManager.getCards(forCardTypeId: cardTypeId) {
            self.cards = Array(cardsList)
        } else {
            self.cards = []
        }
    }
    
    func fetchNotes(forCardId cardId: String) {
        if let notesList = self.realmManager.getNotes(forCardId: cardId) {
            self.notes = Array(notesList)
        } else {
            self.notes = []
        }
    }
    
    func createType(name: String, color: String, description: String, cardQuestions: [String]) {
        if let createdPackId = createdPackId,
           let createdPack = realmManager.getCardPack(forId: createdPackId) {
            let cardType = CardType()
            cardType.id = UUID().uuidString
            cardType.name = name
            cardType.color = color
            cardType.text = description
            
            let cardObjects = cardQuestions.map { question -> Card in
                let card = Card()
                card.id = UUID().uuidString
                card.question = question
                return card
            }
            
            cardType.cards.append(objectsIn: cardObjects)
                
            realmManager.update {
                createdPack.cardTypes.append(cardType)
            }
            
            DispatchQueue.main.async {
                self.fetchAll()
            }
        }
    }
    
    func createCard(question: String) {
        if let selectedSavingType = selectedSavingType,
           let savingType = self.realmManager.getCardType(forId: selectedSavingType.id) {
            let newCard = Card()
            newCard.id = UUID().uuidString
            newCard.question = question
            
            self.realmManager.update {
                savingType.cards.append(newCard)
            }
            
            DispatchQueue.main.async {
                self.fetchAll()
            }
        }
    }
    
    func createNote(text: String) {
        if cardIndex < cards.count,
           let card = self.realmManager.getCard(forId: cards[cardIndex].id),
           let cardType = cards[cardIndex].parentCardType.first {
            let newNote = Note()
            newNote.id = UUID().uuidString
            newNote.text = text
            
            self.realmManager.update {
                card.notes.append(newNote)
            }
            
            DispatchQueue.main.async {
                self.fetchCards(forCardTypeId: cardType.id)
            }
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
        let shareText = "\(Localization.checkOut) \(appName) - \(appURL)"
        return shareText
    }
    
    func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    func addCardToFavorites(_ card: Card) {
        guard let favoritesCardType = realmManager.getCardType(forId: favoriteType?.id ?? "") else {
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
        guard let favoritesCardType = realmManager.getCardType(forId: favoriteType?.id ?? "") else {
            print("Error: 'Favorites' card type not found.")
            isCardFavorite = false
            return
        }
        
        if cardIndex < cards.count {
            isCardFavorite = favoritesCardType.cards.contains { $0.id == cards[cardIndex].id }
        }
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
        fetchAll()
        cardIndex = 0
        cards = []
        cardTypes = []
        isCardFavorite = false
    }
    
}

