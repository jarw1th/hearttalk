//
//  Data+.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 06.02.2025.
//

import Foundation

extension Data: @retroactive Identifiable {
    
    public var id: String {
        "\(self)"
    }
    
}
