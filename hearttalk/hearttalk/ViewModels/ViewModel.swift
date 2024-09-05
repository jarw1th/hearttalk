
import SwiftUI
import RealmSwift

@MainActor
final class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    private var realmManager: RealmManager = RealmManager()
    
    @Published var cardTypes: [CardType] = []
    @Published var cards: [Card] = []
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
    
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
    
}

