
import Foundation
import FirebaseCore
import FirebaseFirestore

final class TextFileManager {
    
    private var realmManager: RealmManager
    
    private let cardTypeNames: [String: Bool] = ["sex": true, "taboo": true, "family": false, "simple": false, "couples": false]
    private var tempCardPacks: [CardPack] = []
    
    init(_ realmManager: RealmManager) {
        self.realmManager = realmManager
    }
    
    func parseCards(_ completion: (() -> Void)? = nil) {
        parseDefaultPacks()
        parseCardsFromTextFiles()
        saveAll()
        completion?()
    }
    
    private func parseDefaultPacks() {
        let langs = Locale.preferredLanguages.map({ String($0.prefix(2)) })
        
        for lang in langs {
            let favoriteCardPack = CardPack(id: UUID().uuidString, name: String.localized("favorites", language: lang))
            favoriteCardPack.color = "D44A13"
            favoriteCardPack.isFavorite = true
            favoriteCardPack.isCustom = false
            favoriteCardPack.language = lang
            
            let favoriteCardType = CardType(id: UUID().uuidString, name: String.localized("favorites", language: lang), text: "")
            favoriteCardType.color = "D44A13"
            favoriteCardType.isFavorite = true
            favoriteCardType.isCustom = false
            favoriteCardType.isAdult = false
            favoriteCardType.language = lang
            
            favoriteCardPack.cardTypes.append(favoriteCardType)
            self.tempCardPacks.append(favoriteCardPack)
            
            let customCardPack = CardPack(id: UUID().uuidString, name: String.localized("created", language: lang))
            customCardPack.color = "b97375"
            customCardPack.isFavorite = false
            customCardPack.isCustom = true
            customCardPack.language = lang
            
            let customCardType = CardType(id: UUID().uuidString, name: String.localized("unsorted", language: lang), text: String.localized("unsortedDesc", language: lang))
            customCardType.color = "b97375"
            customCardType.isFavorite = false
            customCardType.isCustom = true
            customCardType.isAdult = false
            customCardType.language = lang
            
            customCardPack.cardTypes.append(customCardType)
            self.tempCardPacks.append(customCardPack)
        }
    }
    
    private func parseCardsFromTextFiles(_ completion: (() -> Void)? = nil) {
        let langs = Locale.preferredLanguages.map({ String($0.prefix(2)) })
        
        for lang in langs {
            addCardPack(lang: lang)
        }
    }
    
    private func addCardPack(lang: String) {
        let cardPack = CardPack(id: UUID().uuidString, name: String.localized("hearTalkPack", language: lang))
        cardPack.color = "33a7bb"
        cardPack.isFavorite = false
        cardPack.isCustom = false
        cardPack.language = lang
        
        for (name, isAdult) in cardTypeNames {
            addCardType(pack: cardPack, typeName: name, isAdult: isAdult) { type in
                cardPack.cardTypes.append(type)
            }
        }
        self.tempCardPacks.append(cardPack)
    }
    
    private func addCardType(pack cardPack: CardPack, typeName: String, isAdult: Bool, completion: @escaping (CardType) -> Void) {
        if let filePath = Bundle.main.path(forResource: "\(typeName)_\(cardPack.language)", ofType: "txt"),
           readLines(from: filePath).count >= 3 {
            var lines = readLines(from: filePath)
            let cardType = CardType(id: UUID().uuidString, name: lines[0], text: lines[1])
            cardType.color = lines[2]
            cardType.language = cardPack.language
            cardType.isCustom = false
            cardType.isFavorite = false
            cardType.isAdult = isAdult
            lines = Array(lines.dropFirst(3))
            for question in lines {
                let card = Card(id: UUID().uuidString, question: question)
                card.isCustom = false
                card.language = cardPack.language
                cardType.cards.append(card)
            }
            completion(cardType)
        }
    }
    
    private func save(_ pack: CardPack) {
        realmManager.add(pack)
    }
    
    private func saveAll() {
        for cardPack in tempCardPacks {
            self.realmManager.add(cardPack)
        }
        
        tempCardPacks.removeAll()
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
    
}
