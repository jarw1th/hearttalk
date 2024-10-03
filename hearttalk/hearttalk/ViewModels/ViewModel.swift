
import SwiftUI
import RealmSwift
import StoreKit
import AVFoundation

@MainActor
final class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    private var realmManager: RealmManager = RealmManager()
    private var userDefaultsManager: UserDefaultsManager = UserDefaultsManager()
    private var firebaseManager: FirebaseManager
    private(set) var remoteConfigManager: RemoteConfigManager = RemoteConfigManager()
    
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
    
    private(set) var isShowAd: Bool = (Locale.current.regionCode == "RU")
    
    init() {
        self.firebaseManager = FirebaseManager(realmManager)
       
        self.remoteConfigManager.fetchRemoteConfig {
            if !UserDefaultsManager.shared.hasValidData || (self.remoteConfigManager.appData?.isUpdateContent ?? false) {
                self.realmManager.deleteAll()
                self.firebaseManager.parseCards {
                    self.fetchAll()
                    self.getDailyCard()
                }
                UserDefaultsManager.shared.hasValidData = true
            } else {
                self.fetchAll()
                self.getDailyCard()
                if self.cardTypes.isEmpty {
                    self.realmManager.deleteAll()
                    self.firebaseManager.parseCards {
                        self.fetchAll()
                        self.getDailyCard()
                    }
                }
            }
        }
    }
    
    func fetchAll() {
        self.cardTypes = []
        self.myCardTypes = []
        self.favoriteType = nil
        self.selectedSavingType = nil
        let cardTypesResults = self.realmManager.getAllCardTypes()
        
        let lang = userDefaultsManager.appleLanguage
        fetchAllCardPacks(lang)
        self.cardTypes = Array(cardTypesResults).filter { $0.language == lang || $0.language == "none" }
        self.myCardTypes = Array(cardTypesResults).filter { $0.isCustom && $0.language == lang }
        self.favoriteType = cardTypes.filter({ $0.isFavorite }).first
        self.selectedSavingType = cardTypes.filter({ $0.isCustom }).first
    }
    
    func fetchAllCardPacks(_ lang: String) {
        self.cardPacks = []
        let cardPacksResults = self.realmManager.getAllCardPacks()
        
        self.cardPacks = Array(cardPacksResults).filter { !$0.isFavorite && ($0.language == lang || $0.language == "none") }
    }
    
    func fetchAllCardTypes(forCardPackId cardPackId: String) {
        if let cardTypesList = self.realmManager.getCardTypes(forCardPackId: cardPackId) {
            let lang = userDefaultsManager.appleLanguage
            self.cardTypes = Array(cardTypesList).filter { $0.language == lang || $0.language == "none" }
            self.myCardTypes = Array(self.realmManager.getAllCardTypes()).filter { $0.isCustom && $0.language == lang }
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
        let lang = userDefaultsManager.appleLanguage
        if let createdPackId = realmManager.getCustomCardPack(with: lang)?.id,
           let createdPack = realmManager.getCardPack(forId: createdPackId) {
            let cardType = CardType()
            cardType.id = UUID().uuidString
            cardType.name = name
            cardType.color = color
            cardType.text = description
            cardType.language = lang
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
        self.cardTypes = []
        self.myCardTypes = []
        self.favoriteType = nil
        self.selectedSavingType = nil
        self.dailyCard = nil
        self.dailyOriginalCard = nil
        self.cards = []
        self.notes = []
        cardIndex = 0
        isCardFavorite = false
        
        UserDefaultsManager.shared.hasValidData = false
        
//        realmManager.deleteAll()
//        firebaseManager.parseCards {
//            self.fetchAll()
//            self.getDailyCard()
//        }
    }
    
    func getDailyCard() {
        let today = Calendar.current.startOfDay(for: Date())
        let cardsList = realmManager.fetch(Card.self)
        let lang = userDefaultsManager.appleLanguage
        let cards = Array(cardsList.filter { $0.language == lang })
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
            guard !cards.isEmpty else { return }
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

