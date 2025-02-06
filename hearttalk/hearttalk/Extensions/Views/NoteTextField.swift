//
//  NoteTextField.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct NoteTextField: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextView(text: $text, placeholder: placeholder)
            .padding(16)
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.darkWhite, lineWidth: 1)
                    .opacity(text.isEmpty ? 0.5 : 1)
            )
    }
    
}
