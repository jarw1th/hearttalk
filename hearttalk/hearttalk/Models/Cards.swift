
import RealmSwift

class CardPack: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var color: String
    @Persisted var isAdult: Bool 
    @Persisted var cardTypes: List<CardType>
    
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
    
}

class CardType: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var text: String
    @Persisted var color: String
    @Persisted var cards: List<Card>
    @Persisted(originProperty: "cardTypes") var parentCardPack: LinkingObjects<CardPack>
    
    convenience init(id: String, name: String, text: String) {
        self.init()
        self.id = id
        self.name = name
        self.text = text
    }
    
}

class Card: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var question: String
    @Persisted var notes: List<Note>
    @Persisted(originProperty: "cards") var parentCardType: LinkingObjects<CardType>
    
    convenience init(id: String, question: String) {
        self.init()
        self.id = id
        self.question = question
    }
    
}

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

class DailyCard: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var question: String
    @Persisted var cardId: String
    @Persisted var date: Date
    
    convenience init(id: String, question: String) {
        self.init()
        self.id = id
        self.question = question
    }
    
}
