
import RealmSwift

class CardPack: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var color: String
    @Persisted var language: String = "none"
    @Persisted var isAdult: Bool
    @Persisted var isCustom: Bool
    @Persisted var isFavorite: Bool
    @Persisted var cardTypes: List<CardType>
    
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
    
}
