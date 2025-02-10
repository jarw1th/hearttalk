
import SwiftUI
import RealmSwift
import StoreKit
import AVFoundation

@MainActor
final class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    private var realmManager: RealmManager = RealmManager()
    private var userDefaultsManager: UserDefaultsManager = UserDefaultsManager()
    private(set) var network: RequestManager = RequestManager.shared
    private var textFileManager: TextFileManager
    
    @Published var myPacks: [Pack] = []
    @Published var htPacks: [String: [Pack]] = [:]
    @Published var cards: [Card] = []
    @Published var notes: [Note] = []
    @Published var cardIndex: Int = 0 {
        didSet {
            updateCardFavoriteStatus()
        }
    }
    @Published var noteIndex: Int = 0 
    @Published var isCardFavorite: Bool = false
    @Published var favoriteType: Pack?
    @Published var selectedSavingType: Pack?
    @Published var dailyCard: DailyCard?
    @Published var dailyOriginalCard: Card?
    @Published var selectedCards: [Card] = []
    @Published var selectedNotes: [Note] = []
    
    @Published var isOnline: Bool = false
    
    private(set) var isShowAd: Bool = (Locale.current.regionCode == "RU")
    
    init() {
        self.textFileManager = TextFileManager(realmManager)
        
        if userDefaultsManager.isOnline && userDefaultsManager.offlineHourDate?.isMoreHour() != false {
            self.isOnline = true
        }
        
        if !UserDefaultsManager.shared.hasValidData {
            self.realmManager.deleteAll()
            self.textFileManager.parseCards {
                self.fetchAll()
                self.getDailyCard()
            }
            UserDefaultsManager.shared.hasValidData = true
        } else {
            self.fetchAll()
            self.getDailyCard()
            if self.htPacks.isEmpty {
                self.realmManager.deleteAll()
                self.textFileManager.parseCards {
                    self.fetchAll()
                    self.getDailyCard()
                }
            }
        }
    }
    
    func fetchAll() {
        self.favoriteType = nil
        self.selectedSavingType = nil
        let packsResults = self.realmManager.getAllPacks()
        
        let lang = userDefaultsManager.appleLanguage
        let allPacks = Array(packsResults).filter { ($0.language == lang || $0.language == "none") && $0.creator == "ht" }.sorted(by: { $0.name > $1.name })
        for pack in allPacks {
            if self.htPacks[pack.categorie] == nil {
                self.htPacks[pack.categorie] = []
            }
            self.htPacks[pack.categorie]?.append(pack)
        }
        self.myPacks = Array(packsResults).filter { ($0.language == lang || $0.language == "none") && $0.creator == "me" }.sorted {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite
            }
            return $0.name < $1.name
        }
        self.favoriteType = Array(packsResults).filter { ($0.language == lang || $0.language == "none") && $0.isFavorite }.first
        self.selectedSavingType = myPacks.first
    }
    
    func fetchCards(forPackId packId: String) {
        if let cardsList = self.realmManager.getCards(forPackId: packId) {
            self.cards = Array(cardsList)
            if userDefaultsManager.isShuffleCards {
                self.cards = self.cards.shuffled()
            }
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
    
    func createPack(name: String, color: String, description: String, cardQuestions: [String]) -> Pack {
        let pack = Pack()
        pack.id = UUID().uuidString
        pack.name = name
        pack.color = color
        pack.text = description
        pack.creator = "me"
        pack.isCustom = true
        
        let cardObjects = cardQuestions.map { question -> Card in
            let card = Card()
            card.id = UUID().uuidString
            card.question = question
            return card
        }
        
        pack.cards.append(objectsIn: cardObjects)
            
        realmManager.add(pack)
        
        DispatchQueue.main.async {
            self.fetchAll()
        }
        
        return pack
    }
    
    func deletePack(_ pack: Pack) {
        if let packInstance = self.realmManager.getPack(forId: pack.id) {
            self.realmManager.delete(packInstance)
            
            DispatchQueue.main.async {
                self.myPacks.removeAll(where: { $0 == pack })
                for (key, var packs) in self.htPacks {
                    packs.removeAll(where: { $0 == pack })
                    self.htPacks[key] = packs
                }
                self.cards = []
                self.fetchAll()
            }
        }
    }
    
    func updatePack(_ newPack: Pack) {
        if let packInstance = self.realmManager.getPack(forId: newPack.id) {
            self.realmManager.update {
                packInstance.name = newPack.name
                packInstance.text = newPack.text
            }
            fetchAll()
        }
    }
    
    func updateCard(_ newCard: Card, for pack: Pack?) {
        if let cardInstance = self.realmManager.getCard(forId: newCard.id) {
            self.realmManager.update {
                cardInstance.question = newCard.question
                if cardInstance.isFlipCard {
                    cardInstance.answer = newCard.answer
                }
            }
            if let pack {
                fetchCards(forPackId: pack.id)
            }
        }
    }
    
    func removeLink(_ card: Card) {
        if let cardInstance = self.realmManager.getCard(forId: card.id) {
            self.realmManager.update {
                cardInstance.link = ""
            }
            if let index = cards.firstIndex(where: { $0 == card }) {
                self.cards[index] = cardInstance
            }
        }
    }
    
    func addLink(_ link: String, for card: Card) {
        if let cardInstance = self.realmManager.getCard(forId: card.id) {
            self.realmManager.update {
                cardInstance.link = link
            }
        }
    }
    
    func createCard(question: String, answer: String, isFlipCard: Bool) {
        if let selectedSavingType = selectedSavingType,
           let savingPack = self.realmManager.getPack(forId: selectedSavingType.id) {
            let newCard = Card()
            newCard.id = UUID().uuidString
            newCard.question = question
            newCard.isFlipCard = isFlipCard
            if isFlipCard {
                newCard.answer = answer
            }
            newCard.creator = "me"
            
            self.realmManager.update {
                savingPack.cards.append(newCard)
            }
            
            DispatchQueue.main.async {
                self.fetchAll()
            }
        }
    }
    
    func deleteCard(_ card: Card, from pack: Pack?) {
        if card.parentPack.count == 1 || pack == nil,
           let cardInstance = self.realmManager.getCard(forId: card.id) {
            self.realmManager.delete(cardInstance)
            
            DispatchQueue.main.async {
                self.cards.removeAll(where: { $0 == card })
            }
        } else if let pack,
                  let packInstance = self.realmManager.getPack(forId: pack.id),
                  let index = packInstance.cards.firstIndex(of: card) {
            self.realmManager.update {
                packInstance.cards.remove(at: index)
            }
            
            DispatchQueue.main.async {
                self.cards.removeAll(where: { $0 == card })
            }
        }
    }
    
    func createNote(text: String, image: UIImage?) {
        if cardIndex < cards.count,
           let card = self.realmManager.getCard(forId: cards[cardIndex].id) {
            let newNote = Note()
            newNote.id = UUID().uuidString
            newNote.text = text
            newNote.imageData = image?.jpegData(compressionQuality: 1.0)
            
            self.realmManager.update {
                card.notes.append(newNote)
            }
            
            DispatchQueue.main.async {
                self.fetchNotes(forCardId: card.id)
            }
        }
    }
    
    func deleteNote(_ note: Note) {
        if let cardInstance = self.realmManager.getNote(forId: note.id) {
            self.realmManager.delete(cardInstance)
            
            DispatchQueue.main.async {
                self.notes.removeAll(where: { $0 == note })
            }
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
        guard let favoritesCardType = realmManager.getPack(forId: favoriteType?.id ?? "") else {
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
    
    func addCard(_ card: Card, to pack: Pack) {
        realmManager.update {
            pack.cards.append(card)
        }
        
        updateCardFavoriteStatus()
    }
    
    func removeCard(_ card: Card, from pack: Pack) {
        if let existingCard = pack.cards.first(where: { $0.id == card.id }) {
            realmManager.update {
                if let index = pack.cards.firstIndex(of: existingCard) {
                    pack.cards.remove(at: index)
                }
            }
            print("Card removed from Favorites.")
            
            
        }
        
        updateCardFavoriteStatus()
    }
    
    func updateCardFavoriteStatus() {
        guard let favoritesCardType = realmManager.getPack(forId: favoriteType?.id ?? "") else {
            print("Error: 'Favorites' card type not found.")
            isCardFavorite = false
            return
        }
        
        if cardIndex < cards.count {
            isCardFavorite = favoritesCardType.cards.contains { $0.id == cards[cardIndex].id }
        }
    }
    
    func clearData() {
        UserDefaultsManager.shared.hasValidData = false
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
    
    func deleteCards(from pack: Pack?) {
        guard !selectedCards.isEmpty else { return }
        for card in selectedCards {
            if card.parentPack.count == 1 || pack == nil,
               let cardInstance = self.realmManager.getCard(forId: card.id) {
                self.realmManager.delete(cardInstance)
            } else if let pack,
                      let packInstance = self.realmManager.getPack(forId: pack.id),
                      let index = packInstance.cards.firstIndex(of: card) {
                self.realmManager.update {
                    packInstance.cards.remove(at: index)
                }
            }
        }
        DispatchQueue.main.async {
            self.cards.removeAll(where: { self.selectedCards.contains($0) })
            self.selectedCards = []
        }
    }
    
    func isSelected() -> Bool {
        selectedCards == cards
    }
    
    func shuffle() {
        cards = cards.shuffled()
    }
    
    func deleteNotes(for card: Card) {
        guard !selectedNotes.isEmpty else { return }
        for note in selectedNotes {
            if let cardInstance = self.realmManager.getNote(forId: note.id) {
                self.realmManager.delete(cardInstance)
            }
        }
        
        DispatchQueue.main.async {
            self.notes.removeAll(where: { self.selectedNotes.contains($0) })
            self.selectedNotes = []
        }
    }
    
    func networkMode() {
        guard !isOnline else {
            isOnline = false
            return
        }
        if network.isConnected {
            isOnline = true
            userDefaultsManager.isOnline = true
            userDefaultsManager.offlineHourDate = Date.distantPast
        }
    }
    
    func setOfflineHour() {
        userDefaultsManager.offlineHourDate = Date()
        isOnline = false
    }
    
    func setOffline() {
        userDefaultsManager.isOnline = false
        isOnline = false
    }
    
    func importFrom(_ file: URL, for pack: Pack) {
        guard file.startAccessingSecurityScopedResource() else {
            print("Ошибка доступа к файлу")
            return
        }
        defer { file.stopAccessingSecurityScopedResource() }
        
        let lines = readLines(from: file.path)
        
        for line in lines {
            let separatedTexts = line.components(separatedBy: "/")
            let card = Card(id: UUID().uuidString, question: separatedTexts.isEmpty ? line : separatedTexts[0])
            card.isFlipCard = separatedTexts.count > 1
            if separatedTexts.count > 1 {
                card.answer = separatedTexts[1]
            }
            if let packInstance = self.realmManager.getPack(forId: pack.id) {
                realmManager.update {
                    packInstance.cards.append(card)
                }
            }
        }
        
        fetchAll()
    }
    
    func importFromText(_ file: URL, for pack: Pack) {
        guard file.startAccessingSecurityScopedResource() else {
            print("Ошибка доступа к файлу")
            return
        }
        defer { file.stopAccessingSecurityScopedResource() }
        
        let fileExt = detectFileTypeFromContent(from: file.path)
        guard let fileExt else { return }
        
        let lines = readLines(from: file.path)
        
        let separatedBy = fileExt.lowercased() == "csv" ? "," : "\t"
        for line in lines {
            let separatedTexts = line.components(separatedBy: separatedBy)
            guard separatedTexts.count > 1 else { continue }
            
            let card = Card(id: UUID().uuidString, question: separatedTexts[0])
            card.isFlipCard = true
            card.answer = separatedTexts[1]
            if let packInstance = self.realmManager.getPack(forId: pack.id) {
                realmManager.update {
                    packInstance.cards.append(card)
                }
            }
        }
        
        fetchAll()
    }
    
    private func readLines(from filePath: String) -> [String] {
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = fileContents.components(separatedBy: .newlines)
            return lines.filter { !$0.isEmpty }
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            return []
        }
    }
    
    private func detectFileTypeFromContent(from filePath: String) -> String? {
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            if content.contains(",") && content.contains("\n") {
                return "csv"
            } else if content.contains("\t") {
                return "txt"
            }
        } catch {
            print("Error reading file: \(error.localizedDescription)")
        }
        return nil
    }
    
    func generate(from prompt: String, using pack: Pack, with cards: Int) {
        
    }
    
    func savePack(_ pack: Pack) {
        realmManager.add(pack)
        
        DispatchQueue.main.async {
            self.fetchAll()
        }
    }
    
}

