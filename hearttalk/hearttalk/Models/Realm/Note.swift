
import RealmSwift

class Note: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var text: String
    @Persisted(originProperty: "notes") var parentCard: LinkingObjects<Card>
    
    convenience init(id: String, text: String) {
        self.init()
        self.id = id
        self.text = text
    }
    
}
