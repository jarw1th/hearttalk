//
//  OnlineSwitcher.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 25.01.2025.
//

import SwiftUI

struct OnlineSwitcher: View {
    
    @Binding var selected: OnlineSearchType
    
    var body: some View {
        makeContent()
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        HStack {
            ForEach(OnlineSearchType.allCases.indices, id: \.self) { index in
                makeElement(OnlineSearchType.allCases[index])
                if OnlineSearchType.allCases.count - 1 != index {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
        )
    }
    
    @ViewBuilder
    private func makeElement(_ element: OnlineSearchType) -> some View {
        Button {
            selected = element
        } label: {
            Text(element.value)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .foregroundColor(element == selected ? .darkWhite : .lightBlack)
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
                .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(element == selected ? .darkGreen : .clear)
                )
        }
    }
    
}
