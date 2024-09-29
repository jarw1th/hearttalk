
import RealmSwift

class CardType: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var text: String
    @Persisted var color: String
    @Persisted var isCustom: Bool
    @Persisted var cards: List<Card>
    @Persisted(originProperty: "cardTypes") var parentCardPack: LinkingObjects<CardPack>
    
    convenience init(id: String, name: String, text: String) {
        self.init()
        self.id = id
        self.name = name
        self.text = text
    }
    
}
