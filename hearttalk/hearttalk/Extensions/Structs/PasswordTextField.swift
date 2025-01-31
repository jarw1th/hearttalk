//
//  PasswordTextField.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 31.01.2025.
//

import SwiftUI

struct PasswordTextField: View {
    
    let placeholder: String
    @Binding var text: String
    
    @State private var isShowPassword: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundColor(.lightBlack)
                    .opacity(0.5)
            }
            if isShowPassword {
                TextField("", text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundStyle(.lightBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                SecureField("", text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundStyle(.lightBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Spacer()
                Button {
                    isShowPassword.toggle()
                } label: {
                    Icon(name: isShowPassword ? "eyeCrossed" : "eye", size: .custom(20), color: .lightBlack)
                        .opacity(isShowPassword ? 0.5 : 1)
                }
            }
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.darkWhite)
        )
    }
    
}
