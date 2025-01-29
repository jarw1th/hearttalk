//
//  Untitled.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct CustomTextField: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundColor(.lightBlack)
                    .opacity(0.5)
            }
            TextField("", text: $text)
                .autocapitalization(.sentences)
                .disableAutocorrection(true)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.darkWhite)
        )
    }
    
}
