//
//  TagsTextField.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct TagsTextField: View {
    
    let placeholder: String
    @Binding var tags: [String]
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(tags) { tag in
                        Button {
                            tags.removeAll(where: { $0 == tag })
                        } label: {
                            Text(tag)
                                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                                .foregroundColor(.darkWhite)
                                .padding(.horizontal, 8)
                                .frame(maxHeight: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.lightBlack)
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 30)
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
                    .focused($isFocused)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.darkWhite)
        )
        .onChange(of: isFocused) { newValue in
            guard !newValue,
                  !tags.contains(text),
                  text.count < 12,
                  !text.isEmpty else { return }
            if tags.count > 5 {
                tags.removeFirst()
                tags.append(text)
                text = ""
            } else {
                tags.append(text)
                text = ""
            }
        }
        .onChange(of: text) { _ in
            text = text.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
        }
    }
    
}
