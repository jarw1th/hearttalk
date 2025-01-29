
import Foundation
import FirebaseCore
import FirebaseFirestore

final class TextFileManager {
    
    private var realmManager: RealmManager
    
    private let cardTypeNames: [String: Bool] = ["sex": true, "taboo": true, "family": false, "simple": false, "couples": false]
    private let quizNames: [String: Bool] = ["countries_quiz": false]
    private var tempCardPacks: [Pack] = []
    
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
            let favoritePack = Pack(id: UUID().uuidString, name: String.localized("favorites", language: lang), text: "")
            favoritePack.color = "D44A13"
            favoritePack.isFavorite = true
            favoritePack.isCustom = false
            favoritePack.language = lang
            favoritePack.creator = "me"
            favoritePack.isAdult = false
            
            self.tempCardPacks.append(favoritePack)
        }
    }
    
    private func parseCardsFromTextFiles(_ completion: (() -> Void)? = nil) {
        let langs = Locale.preferredLanguages.map({ String($0.prefix(2)) })
        
        for lang in langs {
            for (name, isAdult) in cardTypeNames {
                addPack(name: name, isAdult: isAdult, lang: lang) { [weak self] pack in
                    self?.tempCardPacks.append(pack)
                }
            }
            
            for (name, isAdult) in quizNames {
                addQuizPack(name: name, isAdult: isAdult, lang: lang) { [weak self] pack in
                    self?.tempCardPacks.append(pack)
                }
            }
        }
    }
    
    private func addPack(name: String, isAdult: Bool, lang: String, completion: @escaping (Pack) -> Void) {
        if let filePath = Bundle.main.path(forResource: "\(name)_\(lang)", ofType: "txt"),
           readLines(from: filePath).count >= 3 {
            var lines = readLines(from: filePath)
            let pack = Pack(id: UUID().uuidString, name: lines[0], text: lines[1])
            pack.color = lines[2]
            pack.language = lang
            pack.isCustom = false
            pack.isFavorite = false
            pack.isAdult = isAdult
            lines = Array(lines.dropFirst(3))
            for question in lines {
                let card = Card(id: UUID().uuidString, question: question)
                card.isFlipCard = false
                card.language = pack.language
                pack.cards.append(card)
            }
            completion(pack)
        }
    }
    
    private func addQuizPack(name: String, isAdult: Bool, lang: String, completion: @escaping (Pack) -> Void) {
        if let filePath = Bundle.main.path(forResource: "\(name)_\(lang)", ofType: "txt"),
           readLines(from: filePath).count >= 3 {
            var lines = readLines(from: filePath)
            let pack = Pack(id: UUID().uuidString, name: lines[0], text: "")
            pack.color = lines[1]
            pack.language = lang
            pack.isCustom = false
            pack.isFavorite = false
            pack.isAdult = isAdult
            pack.creator = "htq"
            lines = Array(lines.dropFirst(3))
            for text in lines {
                let separatedTexts = text.components(separatedBy: "/")
                guard separatedTexts.count > 1 else { continue }
                let card = Card(id: UUID().uuidString, question: separatedTexts[0])
                card.answer = separatedTexts[1]
                card.isFlipCard = true
                card.language = pack.language
                pack.cards.append(card)
            }
            completion(pack)
        }
    }
    
    private func save(_ pack: Pack) {
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
