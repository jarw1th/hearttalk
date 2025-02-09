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
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(tags) { tag in
                        Button {
                            tags.removeAll(where: { $0 == tag })
                        } label: {
                            Text(tag)
                                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                                .foregroundColor(.lightBlack)
                                .padding(.horizontal, 8)
                                .frame(maxHeight: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.darkWhite)
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                        .foregroundColor(.darkWhite)
                        .opacity(0.5)
                }
                TextField("", text: $text)
                    .autocapitalization(.sentences)
                    .disableAutocorrection(true)
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .focused($isFocused)
                    .frame(height: 36)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.darkWhite, lineWidth: 1)
                    .opacity(!text.isEmpty || !tags.isEmpty ? 1 : 0.5)
            )
        }
        .onChange(of: isFocused) { newValue in
            text = text.replacingOccurrences(of: " ", with: "")
            guard !newValue,
                  !tags.contains(text),
                  text.count < 12,
                  !text.isEmpty else {
                text = ""
                return
            }
            if tags.count > 5 {
                tags.removeFirst()
                tags.append(text)
                text = ""
            } else {
                tags.append(text)
                text = ""
            }
        }
    }
    
}
