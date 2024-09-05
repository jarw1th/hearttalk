
import SwiftUI
import RealmSwift

@MainActor
final class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    @State private var realmManager = RealmManager()
    
    @Published var cardTypes: [CardType] = []
    @Published var cards: [Card] = []
    
    private let hasImportedDataKey = "hasImportedData"
    
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
            ("Family", "family")
        ]
        
        for (cardTypeName, fileName) in cardTypesWithFileNames {
            addCardType(withName: cardTypeName, fromFile: fileName)
        }
    }
    
    private func addCardType(withName name: String, fromFile fileName: String) {
        print("Attempting to add card type from file: \(fileName)")
        do {
            if let fileContents = try? readTextFile(fileName: fileName) {
                print("File contents for \(fileName): \(fileContents)") // Verify file contents
                let lines = fileContents.components(separatedBy: .newlines)
                
                guard let colorLine = lines.first(where: { $0.starts(with: "Color:") }) else {
                    print("Error: No color found in file \(fileName)")
                    return
                }
                
                let colorValue = colorLine.replacingOccurrences(of: "Color:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                let cardType = CardType(id: UUID().uuidString, name: name)
                cardType.color = colorValue
                
                let questions = lines.dropFirst().filter { !$0.isEmpty && !$0.starts(with: "Color:") }
                
                for question in questions {
                    let card = Card(id: UUID().uuidString, question: question)
                    cardType.cards.append(card)
                }
                
                realmManager.add(cardType)
                print("Added CardType: \(cardType)")
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
        let cardTypesResults = realmManager.getAllCardTypes()
        cardTypes = Array(cardTypesResults)
    }
    
    func fetchCards(forCardTypeId cardTypeId: String) {
        if let cardsList = realmManager.getCards(forCardTypeId: cardTypeId) {
            cards = Array(cardsList)
        } else {
            cards = []
        }
    }
    
}

