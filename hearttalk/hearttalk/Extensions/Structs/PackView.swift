//
//  PackView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct PackView: View {
    
    var color: String
    var name: String
    var numberOfCards: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: color))
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                let value = (numberOfCards == 1 ? "card" : "cards")
                let text = numberOfCards <= 0 ? "empty" : "\(numberOfCards) \(value)"
                Text(text)
                    .font(.custom("Poppins-Regular", size: 12))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .frame(width: 200, height: 140)
    }
    
}
