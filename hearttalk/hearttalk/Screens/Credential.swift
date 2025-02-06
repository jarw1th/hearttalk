//
//  Credential.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 05.02.2025.
//

import SwiftUI

struct Credential: View {
    
    @Environment(\.dismiss) var dismiss
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    @State private var link: String? = nil
    @State private var isShowAlert: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text(Localization.alert), message: Text(Localization.packNameAlert), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
            .sheet(item: $link) { link in
                if let url = URL(string: link) {
                    SafariViewController(url: url)
                }
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            SingleBackTopBar(text: "Credential") {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Image("Credential")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    Text("Ruslan Parastaev")
                        .font(.custom("Poppins-Regular", size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.darkWhite)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                SettingsButton(text: "Telegram") {
                    link = "https://www.t.me/jarw1th"
                }
                Spacer()
                HStack {
                    Text("app version:")
                        .font(.custom("Poppins-Regular", size: 12))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.darkWhite)
                    Text(appVersion)
                        .font(.custom("Poppins-Regular", size: 12))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.darkWhite)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
}
