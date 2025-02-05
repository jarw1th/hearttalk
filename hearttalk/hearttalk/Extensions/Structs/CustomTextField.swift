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
        case cardNumber
        
        var keyboard: UIKeyboardType {
            switch self {
            case .def:
                .default
            case .numeric:
                .numberPad
            case .cardNumber:
                .numberPad
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundColor(.darkWhite)
                    .opacity(0.5)
            }
            TextField("", text: $text)
                .autocapitalization(.sentences)
                .keyboardType(type.keyboard)
                .disableAutocorrection(true)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .foregroundStyle(.darkWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .onChange(of: text) { newValue in
            if type == .numeric {
                text = text.filter({ $0.isNumber })
            }
            if type == .cardNumber {
                text = text.filter({ $0.isNumber })
                if !isLess49(text) {
                    text = "1"
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.darkWhite, lineWidth: 1)
                .opacity(text.isEmpty ? 0.5 : 1)
        )
    }
    
    private func isLess49(_ string: String) -> Bool {
        guard let num = Int(string) else { return false }
        return num < 49 && num > 0
    }
    
}
