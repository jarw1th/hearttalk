//
//  Untitled.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct CustomTextField: View {
    
    let placeholder: String
    var type: TextFieldType = .def
    @Binding var text: String
    
    enum TextFieldType {
        case def
        case numeric
        
        var keyboard: UIKeyboardType {
            switch self {
            case .def:
                .default
            case .numeric:
                .numberPad
            }
        }
    }
    
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
                .keyboardType(type.keyboard)
                .disableAutocorrection(true)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .onChange(of: text) { newValue in
            guard type == .numeric else { return }
            text = text.filter({ $0.isNumber })
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.darkWhite)
        )
    }
    
}
