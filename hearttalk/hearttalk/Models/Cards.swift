
import RealmSwift

class CardType: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var color: String
    @Persisted var cards: List<Card>
    
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
    
}

class Card: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var question: String
    @Persisted(originProperty: "cards") var parentCardType: LinkingObjects<CardType>
    
    convenience init(id: String, question: String) {
        self.init()
        self.id = id
        self.question = question
    }
    
}
