//
//  OnlineAccountInfo.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 04.02.2025.
//

import SwiftUI

struct OnlineAccountInfo: View {
    
    var lastSeen: Date?
    var email: String?
    
    var body: some View {
        makeAccountInfo(lastSeen: lastSeen, email: email)
    }
    
    @ViewBuilder
    private func makeAccountInfo(lastSeen: Date?, email: String?) -> some View {
        VStack(spacing: 16) {
            if let lastSeen {
                makeText(title: "Last seen:", value: timeAgoSince(lastSeen))
            }
            if let email {
                makeText(title: "E-mail:", value: email)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private func makeText(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("Poppins-Regular", size: 16))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.darkWhite)
            Text(value)
                .font(.custom("Poppins-Regular", size: 16))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.darkWhite.opacity(0.5))
            Spacer()
        }
    }
    
}

struct OnlineAccountCredential: View {
    
    var image: URL?
    var name: String
    @Binding var isShowAvatarPicker: Bool
    
    var body: some View {
        makeAccountCreds(image: image, name: name)
    }
    
    @ViewBuilder
    private func makeAccountCreds(image: URL?, name: String?) -> some View {
        VStack(spacing: 16) {
            Button {
                isShowAvatarPicker.toggle()
            } label: {
                AsyncImage(url: image) { img in
                    img
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    Icon(name: "addImage", size: .custom(80))
                }
            }
            Text(name ?? "No name")
                .font(.custom("Poppins-Regular", size: 24))
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

}
