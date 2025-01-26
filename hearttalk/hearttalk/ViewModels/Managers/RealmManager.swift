
import Foundation
import RealmSwift

final class RealmManager {
    
    private var realm: Realm
    
    init() {
        do {
            let config = Realm.Configuration(
                fileURL: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ruslanparastaev.hearttalk")?.appendingPathComponent("default.realm"),
                schemaVersion: 1,
                migrationBlock: { _, _ in }
            )
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
        } catch let error {
            fatalError("Unable to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    func write(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch {
            print("Failed to write to Realm: \(error)")
        }
    }
    
    func add<T: Object>(_ object: T) {
        guard !object.isInvalidated else { return }
        do {
            try realm.write {
                realm.add(object)
            }
        } catch let error {
            print("Error adding object to Realm: \(error.localizedDescription)")
        }
    }
    
    func delete<T: Object>(_ object: T) {
        guard !object.isInvalidated else { return }
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch let error {
            print("Error deleting object from Realm: \(error.localizedDescription)")
        }
    }
    
    func update(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch let error {
            print("Error updating object in Realm: \(error.localizedDescription)")
        }
    }
    
    func fetch<T: Object>(_ objectType: T.Type) -> Results<T> {
        return realm.objects(objectType)
    }
    
    func fetch<T: Object>(_ objectType: T.Type, predicate: NSPredicate) -> Results<T> {
        return realm.objects(objectType).filter(predicate)
    }
    
    func deleteAll<T: Object>(_ objectType: T.Type) {
        do {
            try realm.write {
                let objects = realm.objects(objectType)
                realm.delete(objects)
            }
        } catch let error {
            print("Error deleting all objects from Realm: \(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch let error {
            print("Error deleting all objects from Realm: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Custom
    
    func getAllCardPacks() -> Results<CardPack> {
        return realm.objects(CardPack.self)
    }
    
    func getAllCardTypes() -> Results<CardType> {
        return realm.objects(CardType.self)
    }
    
    func getCardTypes(forCardPackId cardPackId: String) -> List<CardType>? {
        guard let cardPack = realm.object(ofType: CardPack.self, forPrimaryKey: cardPackId) else {
            return nil
        }
        return cardPack.cardTypes
    }
    
    func getCards(forCardTypeId cardTypeId: String) -> List<Card>? {
        guard let cardType = realm.object(ofType: CardType.self, forPrimaryKey: cardTypeId) else {
            return nil
        }
        return cardType.cards
    }
    
    func getNotes(forCardId cardId: String) -> List<Note>? {
        guard let card = realm.object(ofType: Card.self, forPrimaryKey: cardId) else {
            return nil
        }
        return card.notes
    }
    
    func getCardPack(forId id: String) -> CardPack? {
        return realm.object(ofType: CardPack.self, forPrimaryKey: id)
    }
    
    func getCardPack(forName name: String) -> CardPack? {
        return realm.objects(CardPack.self).filter("name == %@", name).first
    }
    
    func getCustomCardPack(with lang: String) -> CardPack? {
        return realm.objects(CardPack.self).filter("isCustom == %@", true).filter("language == %@", lang).first
    }
    
    func getCardType(forId id: String) -> CardType? {
        return realm.object(ofType: CardType.self, forPrimaryKey: id)
    }
    
    func getCardType(forName name: String) -> CardType? {
        return realm.objects(CardType.self).filter("name == %@", name).first
    }
    
    func getCard(forId id: String) -> Card? {
        return realm.object(ofType: Card.self, forPrimaryKey: id)
    }
    
    func getNote(forId id: String) -> Note? {
        return realm.object(ofType: Note.self, forPrimaryKey: id)
    }
    
}
