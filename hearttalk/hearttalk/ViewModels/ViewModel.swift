
import SwiftUI
import RealmSwift

@MainActor
final class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    private var realmManager: RealmManager = RealmManager()
    
    @Published var cardTypes: [CardType] = []
    @Published var cards: [Card] = []
    @Published var cardIndex: Int = 0
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
    
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
        let cardTypesResults = self.realmManager.getAllCardTypes()
        
        self.cardTypes = Array(cardTypesResults)
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
    
}

