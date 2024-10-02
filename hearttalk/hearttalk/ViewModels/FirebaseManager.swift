
import Foundation
import FirebaseCore
import FirebaseFirestore

final class FirebaseManager {
    
    private var realmManager: RealmManager
    
    private let db = Firestore.firestore()
    private let cardsCollection = Firestore.firestore().collection("cards")
    private let defaultCards = Firestore.firestore().collection("cards").document("default")
    private let contentKey = "content"
    
    private var tempCardPacks: [CardPack] = []
    
    init(_ realmManager: RealmManager) {
        self.realmManager = realmManager
    }
    
    func parseCards(_ completion: (() -> Void)? = nil) {
        parseDefaultPacks()
        parseCardsFromFirebase(completion)
    }
    
    private func parseDefaultPacks() {
        let langs = Locale.preferredLanguages.map({ String($0.prefix(2)) })
        
        for lang in langs {
            let favoriteCardPack = CardPack(id: UUID().uuidString, name: String.localized("favorites", language: lang))
            favoriteCardPack.color = "D44A13"
            favoriteCardPack.isAdult = false
            favoriteCardPack.isFavorite = true
            favoriteCardPack.isCustom = false
            favoriteCardPack.language = lang
            
            let favoriteCardType = CardType(id: UUID().uuidString, name: String.localized("favorites", language: lang), text: "")
            favoriteCardType.color = "D44A13"
            favoriteCardType.isFavorite = true
            favoriteCardType.isCustom = false
            favoriteCardType.language = lang
            
            favoriteCardPack.cardTypes.append(favoriteCardType)
            self.tempCardPacks.append(favoriteCardPack)
            
            let customCardPack = CardPack(id: UUID().uuidString, name: String.localized("created", language: lang))
            customCardPack.color = "b97375"
            customCardPack.isAdult = false
            customCardPack.isFavorite = false
            customCardPack.isCustom = true
            customCardPack.language = lang
            
            let customCardType = CardType(id: UUID().uuidString, name: String.localized("unsorted", language: lang), text: String.localized("unsortedDesc", language: lang))
            customCardType.color = "b97375"
            customCardType.isFavorite = false
            customCardType.isCustom = true
            customCardType.language = lang
            
            customCardPack.cardTypes.append(customCardType)
            self.tempCardPacks.append(customCardPack)
        }
    }
    
    private func parseCardsFromFirebase(_ completion: (() -> Void)? = nil) {
        let langs = Locale.preferredLanguages.map({ String($0.prefix(2)) })
        let dispatchGroup = DispatchGroup()
        
        for lang in langs {
            dispatchGroup.enter()
            defaultCards.collection(lang).getDocuments { (querySnapshot, error) in
                if let _ = error { return }
                
                for document in querySnapshot?.documents ?? [] {
                    let pack = document.documentID
                    
                    dispatchGroup.enter()
                    self.addCardPack(self.defaultCards.collection(lang), lang: lang, packName: pack) {
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.saveAll()
            completion?()
        }
    }
    
    private func addCardPack(_ collection: CollectionReference, lang: String, packName: String, completion: @escaping () -> Void) {
        collection.document(packName).getDocument { (document, error) in
            if let _ = error { return }
            guard let document = document, document.exists else { return }
            
            let data = document.data() ?? [:]
            let name = data["name"] as? String ?? "Unknown Name"
            let color = data["color"] as? String ?? "Unknown Color"
            let isAdult = data["isAdult"] as? Bool ?? false
            
            let cardPack = CardPack(id: UUID().uuidString, name: name)
            cardPack.color = color
            cardPack.language = lang
            cardPack.isAdult = isAdult
            cardPack.isCustom = false
            cardPack.isFavorite = false
            
            collection.document(packName).collection(self.contentKey).getDocuments { (querySnapshot, error) in
                if let _ = error { return }
                
                let cardTypeDispatchGroup = DispatchGroup()
                
                for document in querySnapshot?.documents ?? [] {
                    let type = document.documentID
                    cardTypeDispatchGroup.enter()
                    
                    self.addCardType(collection.document(packName).collection(self.contentKey), pack: cardPack, typeName: type) { type in
                        cardPack.cardTypes.append(type)
                        cardTypeDispatchGroup.leave()
                    }
                }
                
                cardTypeDispatchGroup.notify(queue: .main) {
                    self.tempCardPacks.append(cardPack)
                    completion()
                }
            }
        }
    }
    
    private func addCardType(_ collection: CollectionReference, pack cardPack: CardPack, typeName: String, completion: @escaping (CardType) -> Void) {
        collection.document(typeName).getDocument { (document, error) in
            if let _ = error { return }
            guard let document = document, document.exists else { return }
            
            let data = document.data() ?? [:]
            let name = data["name"] as? String ?? "Unknown Name"
            let color = data["color"] as? String ?? "Unknown Color"
            let description = data["description"] as? String ?? "Unknown Color"
            let questions = data["questions"] as? [String] ?? []
            
            let cardType = CardType(id: UUID().uuidString, name: name, text: description)
            cardType.color = color
            cardType.language = cardPack.language
            cardType.isCustom = false
            cardType.isFavorite = false
            
            for question in questions {
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
    
}
