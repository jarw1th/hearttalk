import Foundation
import RealmSwift

final class RealmManager {
    
    private var realm: Realm
    
    init() {
        do {
            realm = try Realm()
        } catch let error {
            fatalError("Unable to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    func add<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch let error {
            print("Error adding object to Realm: \(error.localizedDescription)")
        }
    }
    
    func delete<T: Object>(_ object: T) {
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
    
    func getAllCardTypes() -> Results<CardType> {
        return realm.objects(CardType.self)
    }
    
    func getCards(forCardTypeId cardTypeId: String) -> List<Card>? {
        guard let cardType = realm.object(ofType: CardType.self, forPrimaryKey: cardTypeId) else {
            return nil
        }
        return cardType.cards
    }
    
    func getCardType(forId id: String) -> CardType? {
        return realm.object(ofType: CardType.self, forPrimaryKey: id)
    }
    
    func getCardType(forName name: String) -> CardType? {
        return realm.objects(CardType.self).filter("name == %@", name).first
    }
    
}
