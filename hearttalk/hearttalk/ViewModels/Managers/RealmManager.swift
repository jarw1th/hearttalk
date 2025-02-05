
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
    
    func deleteAll<T: Object>(_ objectType: T.Type, where reason: @escaping (T) -> Bool) {
        do {
            try realm.write {
                let objects = realm.objects(objectType)
                let objs = objects.filter({ reason($0) })
                realm.delete(objs)
            }
        } catch let error {
            print("Error deleting object from Realm: \(error.localizedDescription)")
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
    
    func getAllPacks() -> Results<Pack> {
        return realm.objects(Pack.self)
    }
    
    func getCards(forPackId packId: String) -> List<Card>? {
        guard let cardType = realm.object(ofType: Pack.self, forPrimaryKey: packId) else {
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
    
    func getPack(forId id: String) -> Pack? {
        return realm.object(ofType: Pack.self, forPrimaryKey: id)
    }
    
    func getPack(forName name: String) -> Pack? {
        return realm.objects(Pack.self).filter("name == %@", name).first
    }
    
    func getCard(forId id: String) -> Card? {
        return realm.object(ofType: Card.self, forPrimaryKey: id)
    }
    
    func getNote(forId id: String) -> Note? {
        return realm.object(ofType: Note.self, forPrimaryKey: id)
    }
    
}
