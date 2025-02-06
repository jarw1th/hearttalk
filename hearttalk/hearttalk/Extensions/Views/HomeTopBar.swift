//
//  HomeTopBar.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct TopBar: View {
    
    var text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(text)
                .font(.custom("Poppins-Regular", size: 24))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.darkWhite)
                .lineLimit(1)
            Spacer()
        }
    }
    
}
