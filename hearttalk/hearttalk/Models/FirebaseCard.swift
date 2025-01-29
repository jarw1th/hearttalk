//
//  FirebaseCard.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 25.01.2025.
//

struct FirebasePack: Identifiable {
    
    var id: String
    var pack: Pack
    var tags: [String]
    
    init(pack: Pack, tags: [String]) {
        self.id = pack.id
        self.pack = pack
        self.tags = tags
    }
    
}
