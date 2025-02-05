//
//  Profile.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 05.02.2025.
//

import SwiftUI

struct ProfileScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowSignScreen: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .fullScreenCover(isPresented: $isShowSignScreen) {
                SignScreen()
                    .environmentObject(onlineViewModel)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 8) {
            if onlineViewModel.isSignedIn {
                VStack(spacing: 40) {
                    OnlineAccountCredential(image: onlineViewModel.myUser?.photoURL, name: onlineViewModel.myUser?.displayName ?? "No name")
                    if let user = onlineViewModel.myUser {
                        OnlineAccountInfo(lastSeen: user.lastSeen, email: user.email)
                    }
                    makeAccountButtons()
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    LoginButton {
                        isShowSignScreen = true
                    }
                    .padding(60)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private func makeAccountButtons() -> some View {
        VStack(spacing: 16) {
            SettingsButton(text: "Privacy") {
                
            }
            SettingsEraseButton(text: "Password", buttonTitle: "Reset") {
                
            }
        }
        .frame(maxWidth: .infinity)
    }
    
}
