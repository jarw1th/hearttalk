//
//  Cards.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 24.01.2025.
//

import RealmSwift

class Card: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var question: String
    @Persisted var answer: String
    @Persisted var notes: List<Note>
    @Persisted var language: String = "none"
    @Persisted var link: String = ""
    @Persisted var creator: String = "ht"
    @Persisted var isFlipCard: Bool
    @Persisted(originProperty: "cards") var parentPack: LinkingObjects<Pack>
    
    convenience init(id: String, question: String) {
        self.init()
        self.id = id
        self.question = question
    }
    
}

class DailyCard: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var cardId: String
    @Persisted var question: String
    @Persisted var date: Date
    
    convenience init(id: String, question: String) {
        self.init()
        self.id = id
        self.question = question
    }
    
}
