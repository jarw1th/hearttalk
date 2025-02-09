//
//  PrivacyScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 05.02.2025.
//

import SwiftUI

struct PrivacyScreen: View {
    
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isEmail: Bool = false
    @State private var isMyPacks: Bool = false
    @State private var isLastSeen: Bool = false
    @State private var isMyProfile: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                isEmail = onlineViewModel.myUser?.isShowEmail ?? false
                isMyPacks = onlineViewModel.myUser?.isShowMyContent ?? false
                isLastSeen = onlineViewModel.myUser?.isShowStatus ?? false
                isMyProfile = onlineViewModel.myUser?.isShowMyProfile ?? true
            }
            .onChange(of: isEmail) { new in
                guard onlineViewModel.myUser?.isShowEmail != isEmail else { return }
                onlineViewModel.myUser?.isShowEmail = new
                onlineViewModel.updateShowEmail(new)
            }
            .onChange(of: isMyPacks) { new in
                guard onlineViewModel.myUser?.isShowMyContent != isMyPacks else { return }
                onlineViewModel.myUser?.isShowMyContent = new
                onlineViewModel.updateShowContent(new)
            }
            .onChange(of: isLastSeen) { new in
                guard onlineViewModel.myUser?.isShowStatus != isLastSeen else { return }
                onlineViewModel.myUser?.isShowStatus = new
                onlineViewModel.updateShowStatus(new)
            }
            .onChange(of: isMyProfile) { new in
                guard onlineViewModel.myUser?.isShowMyProfile != isMyProfile else { return }
                onlineViewModel.myUser?.isShowMyProfile = new
                onlineViewModel.updateShowProfile(new)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            SingleBackTopBar(text: Localization.privacy) {
                dismiss()
            }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            
            if onlineViewModel.isLoading {
                Spacer()
                LoadingView(isLarge: false)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        makeButtonsList()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private func makeButtonsList() -> some View {
        VStack(spacing: 16) {
            QuestionToggle(text: Localization.showEmail, isOn: $isEmail)
            QuestionToggle(text: Localization.showContent, isOn: $isMyPacks)
            QuestionToggle(text: Localization.showStatus, isOn: $isLastSeen)
            QuestionToggle(text: Localization.showProfile, isOn: $isMyProfile)
        }
    }
    
}
