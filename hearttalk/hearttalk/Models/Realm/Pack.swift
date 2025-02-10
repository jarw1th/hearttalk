
import RealmSwift

class Pack: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var text: String
    @Persisted var color: String
    @Persisted var language: String = "none"
    @Persisted var isAdult: Bool
    @Persisted var isFavorite: Bool
    @Persisted var isCustom: Bool
    @Persisted var creator: String = "ht"
    @Persisted var categorie: String = "none"
    @Persisted var cards: List<Card>
    
    convenience init(id: String, name: String, text: String) {
        self.init()
        self.id = id
        self.name = name
        self.text = text
    }
    
}
