
import SwiftUI
import RealmSwift
import StoreKit
import AVFoundation

@MainActor
final class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    private var realmManager: RealmManager = RealmManager()
    private var userDefaultsManager: UserDefaultsManager = UserDefaultsManager()
    
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
    @Published var dailyCard: DailyCard?
    @Published var dailyOriginalCard: Card?
    
    private(set) var isShowAd: Bool = (Locale.current.region?.identifier == "RU")
    
    private let defaultCardTypes = [Localization.favorites, Localization.simple, Localization.family, Localization.taboo, Localization.sex, Localization.close, Localization.closer, Localization.closest]
    
    init() {
        if !userDefaultsManager.hasValidData {
            clearData()
            userDefaultsManager.hasValidData = true
        }
        if !userDefaultsManager.hasImportedData {
            parseCardTypesFromFile()
            userDefaultsManager.hasImportedData = true
        }
        fetchAll()
        getDailyCard()
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
        let userLanguage = userDefaultsManager.appleLanguage ?? "en"
        
        var cardPack = CardPack(id: UUID().uuidString, name: name)
        for (cardTypeName, description, baseFileName) in cardTypes {
            let fileName = "\(baseFileName)_\(userLanguage)"
            cardPack = addCardType(withPack: cardPack, withTypeName: cardTypeName, withText: description, fromFile: fileName, with: isSpecial ? baseFileName : "\(baseFileName)_en", save: save, isFavorites: isFavorites) ?? CardPack(id: UUID().uuidString, name: name)
        }
        cardPack.isAdult = isAdult
        cardPack.isCustom = save
        
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
        cardType.isCustom = save
        if isFavorites {
            favoriteType = cardType
        }
        
        let questions = lines.dropFirst().filter { !$0.isEmpty && !$0.starts(with: "Pack Color:") && !$0.starts(with: "Type Color:") }
        
        for question in questions {
            let card = Card(id: UUID().uuidString, question: question)
            card.isCustom = save
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
        if let createdPackId = realmManager.getCustomCardPack()?.id,
           let createdPack = realmManager.getCardPack(forId: createdPackId) {
            let cardType = CardType()
            cardType.id = UUID().uuidString
            cardType.name = name
            cardType.color = color
            cardType.text = description
            cardType.isCustom = true
            
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
            newCard.isCustom = true
            
            self.realmManager.update {
                savingType.cards.append(newCard)
            }
            
            DispatchQueue.main.async {
                self.fetchAll()
            }
        }
    }
    
    func deleteCard(card: Card) {
        if card.isCustom,
           let cardInstance = self.realmManager.getCard(forId: card.id) {
            self.realmManager.delete(cardInstance)
            
            if let index = cards.firstIndex(of: card) {
                cards.remove(at: index)
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
    
    func deleteNote(note: Note) {
        if let cardInstance = self.realmManager.getNote(forId: note.id) {
            self.realmManager.delete(cardInstance)
            
            if let index = notes.firstIndex(of: note) {
                notes.remove(at: index)
            }
        }
    }
    
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
    
    func clearData() {
        realmManager.deleteAll()
        parseCardTypesFromFile()
        fetchAll()
        cardIndex = 0
        cards = []
        cardTypes = []
        isCardFavorite = false
        getDailyCard()
    }
    
    func getDailyCard() {
        let today = Calendar.current.startOfDay(for: Date())
        let cardsList = realmManager.fetch(Card.self)
        let cards = Array(cardsList)
        let dailyCardsList = realmManager.fetch(DailyCard.self)
        let dailyCards = Array(dailyCardsList)
        
        if let existingCard = dailyCards.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            realmManager.delete(existingCard)
            
            let newCard = cards[Int.random(in: 0..<cards.count)]
            let newDailyCardId = UUID().uuidString
            let newQuestion = newCard.question
            let newDailyCard = DailyCard(id: newDailyCardId, question: newQuestion)
            newDailyCard.cardId = newCard.id
            newDailyCard.date = today
            self.dailyCard = newDailyCard
            self.dailyOriginalCard = newCard
            realmManager.add(newDailyCard)
        } else if dailyCards.isEmpty {
            let newCard = cards[Int.random(in: 0..<cards.count)]
            let newDailyCardId = UUID().uuidString
            let newQuestion = newCard.question
            let newDailyCard = DailyCard(id: newDailyCardId, question: newQuestion)
            newDailyCard.cardId = newCard.id
            newDailyCard.date = today
            self.dailyCard = newDailyCard
            self.dailyOriginalCard = newCard
            realmManager.add(newDailyCard)
        } else {
            self.dailyCard = dailyCards.first
            self.dailyOriginalCard = realmManager.getCard(forId: dailyCard?.cardId ?? "")
        }
    }
    
}

