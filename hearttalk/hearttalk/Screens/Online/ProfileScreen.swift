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
    @State private var isShowPrivacy: Bool = false
    @State private var isShowReset: Bool = false
    @State private var isShowAvatarPicker: Bool = false
    @State private var image: UIImage?
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .fullScreenCover(isPresented: $isShowSignScreen) {
                SignScreen()
                    .environmentObject(onlineViewModel)
            }
            .fullScreenCover(isPresented: $isShowPrivacy) {
                PrivacyScreen()
                    .environmentObject(onlineViewModel)
            }
            .fullScreenCover(isPresented: $isShowReset) {
                ResetPasswordScreen()
                    .environmentObject(onlineViewModel)
            }
            .sheet(isPresented: $isShowAvatarPicker) {
                PhotoPickerRepresentable(selectedImage: $image)
            }
            .onChange(of: image) { value in
                guard let value else { return }
                onlineViewModel.updateImage(value)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            if onlineViewModel.isSignedIn {
                VStack(spacing: 40) {
                    OnlineAccountCredential(image: onlineViewModel.myUser?.photoURL, name: onlineViewModel.myUser?.displayName ?? "No name", isShowAvatarPicker: $isShowAvatarPicker)
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
                isShowPrivacy.toggle()
            }
            SettingsEraseButton(text: "Password", buttonTitle: "Reset") {
                isShowReset.toggle()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
}
