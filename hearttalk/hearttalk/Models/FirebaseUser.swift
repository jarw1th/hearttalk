//
//  FirebaseUser.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 25.01.2025.
//

import Foundation

struct FirebaseUser: Identifiable, Equatable {
    
    var id: String
    var email: String
    var displayName: String
    var photoURL: URL?
    var lastSeen: Date?
    
}
