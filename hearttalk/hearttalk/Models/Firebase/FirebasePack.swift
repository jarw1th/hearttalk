//
//  FirebaseCard.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 25.01.2025.
//

import Foundation

struct FirebasePack: Identifiable, Equatable {
    
    var id: String
    var pack: Pack
    var tags: [String]
    var user: String
    var cards: Int
    
    init(pack: Pack, tags: [String], user: String, cards: Int) {
        self.id = pack.id
        self.pack = pack
        self.tags = tags
        self.user = user
        self.cards = cards
    }
    
    static func == (lhs: FirebasePack, rhs: FirebasePack) -> Bool {
        return lhs.id == rhs.id 
    }
    
}
