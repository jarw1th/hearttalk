
import SwiftUI
import SafariServices

struct Settings: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowWhatIs: Bool = false
    @State private var isClearAlert: Bool = false
    @State private var isShowSignIn: Bool = false
    @State private var link: String?
    @State private var actionSheetType: SettingsActionSheetType?
    
    @State private var isVibrations: Bool = false
    @State private var isDailyCard: Bool = false
    @State private var isSounds: Bool = false
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
                .edgesIgnoringSafeArea(.bottom)
                .sheet(item: $link) { url in
                    if let url = URL(string: url) {
                        SafariViewController(url: url)
                    }
                }
                .fullScreenCover(isPresented: $isShowWhatIs) {
                    WhatIsTheApp()
                }
                .onAppear {
                    isVibrations = UserDefaultsManager.shared.isVibrations
                    isSounds = UserDefaultsManager.shared.isSounds
                    isDailyCard = UserDefaultsManager.shared.isDailyCard
                }
                .onChange(of: isVibrations) { new in
                    UserDefaultsManager.shared.isVibrations = new
                }
                .onChange(of: isSounds) { new in
                    UserDefaultsManager.shared.isSounds = new
                }
                .onChange(of: isDailyCard) { new in
                    UserDefaultsManager.shared.isDailyCard = new
                }
                .alert(isPresented: $isClearAlert) {
                    Alert(title: Text(Localization.deleting), primaryButton: .destructive(Text(Localization.delete), action: {
                        viewModel.clearData()
                    }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
                }
                .actionSheet(item: $actionSheetType) { type in
                    ActionSheet(
                        title: Text(type.title),
                        message: Text(type.text),
                        buttons: { () -> [Alert.Button] in
                            switch type {
                            case .language:
                                makeLangActionSheetButtons()
                            case .contacts:
                                makeActionSheetButtons()
                            }
                        }()
                    )
                }
                .fullScreenCover(isPresented: $isShowSignIn) {
                    SignScreen()
                        .environmentObject(onlineViewModel)
                }
        }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            SingleBackTopBar(text: Localization.settings) {
                dismiss()
            }
            .padding(.vertical, 16)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    if viewModel.isOnline && viewModel.network.isNetworkAvailable {
                        if onlineViewModel.isSignedIn {
                            OnlineProfile(image: onlineViewModel.getUser()?.photoURL, name: onlineViewModel.getUser()?.displayName ?? "") {
                                onlineViewModel.signOut()
                            }
                        } else {
                            LoginButton {
                                isShowSignIn.toggle()
                            }
                        }
                    }
                    SettingsButton(text: viewModel.isOnline ? Localization.goOffline : Localization.goOnline) {
                        viewModel.networkMode()
                    }
                    .contextMenu {
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            viewModel.setOfflineHour()
                        } label: {
                            Text(Localization.offlineHour)
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            viewModel.setOffline()
                        } label: {
                            Text(Localization.offlineForever)
                        }
                    }
                    makeButtonsList()
                    makeSettingsList()
                }
            }
            makeCridential()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func makeCridential() -> some View {
        VStack(spacing: 4) {
            Image("logoIcon")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40, height: UIDevice.current.userInterfaceIdiom == .phone ? 18 : 34)
                .opacity(0.5)
            Text(Localization.credential)
                .font(.custom("Poppins-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(0.5)
            if UIDevice.current.userInterfaceIdiom == .phone {
                Text("\(Localization.version) \(UserDefaultsManager.shared.appVersion)")
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 10 : 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.darkWhite)
                    .opacity(0.5)
            }
        }
    }
    
    @ViewBuilder
    private func makeButtonsList() -> some View {
        VStack(spacing: 16) {
            SettingsButton(text: Localization.whatIsHT) {
                whatIsAction()
            }
            SettingsButton(text: Localization.terms) {
                termsAction()
            }
            SettingsButton(text: Localization.policy) {
                privacyAction()
            }
            SettingsButton(text: Localization.contacts) {
                contactAction()
            }
        }
    }
    
    @ViewBuilder
    private func makeSettingsList() -> some View {
        VStack(spacing: 16) {
            SettingsToggle(text: Localization.vibrations, isOn: $isVibrations)
            SettingsToggle(text: Localization.sounds, isOn: $isSounds)
            SettingsToggle(text: Localization.dailyCards, isOn: $isDailyCard)
            SettingsValueButton(text: Localization.language, selectedItem: selectedLang()) {
                actionSheetType = .language
            }
            SettingsEraseButton(text: Localization.data) {
                isClearAlert.toggle()
            }
        }
    }
    
    private func selectedLang() -> String {
        let locale = Locale.current
        if let language = locale.localizedString(forLanguageCode: UserDefaultsManager.shared.appleLanguage) {
            return language.capitalized
        }
        return "English"
    }
    
    private func whatIsAction() {
        isShowWhatIs.toggle()
    }
    
    private func contactAction() {
        actionSheetType = .contacts
    }
    
    private func termsAction() {
        link = ""
    }
    
    private func privacyAction() {
        link = ""
    }
    
    private func makeActionSheetButtons() -> [ActionSheet.Button]  {
        var buttons: [ActionSheet.Button] = []
        
        let telegramButton = ActionSheet.Button.default(Text("Telegram"), action: {
            let tg = "https://t.me/hearttalk_app"
            if let url = URL(string: tg) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        })
        buttons.append(telegramButton)
        
        let instButton = ActionSheet.Button.default(Text("Instagram"), action: {
            let inst = "https://instagram.com/hearttalk_app_\(UserDefaultsManager.shared.language)"
            if let url = URL(string: inst) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        })
        buttons.append(instButton)
        
        let emailButton = ActionSheet.Button.default(Text("Mail"), action: {
            let email = "mailto:help.hearttalk@gmail.com"
            if let url = URL(string: email) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    print("Can't open Gmail")
                }
            }
        })
        buttons.append(emailButton)
                                                        
        let button = ActionSheet.Button.cancel(Text(Localization.cancel))
        buttons.append(button)
        
        return buttons
    }
    
    private func makeLangActionSheetButtons() -> [ActionSheet.Button]  {
        var buttons: [ActionSheet.Button] = []
        for code in Bundle.main.localizations {
            let language = Locale(identifier: code).localizedString(forLanguageCode: code)
            
            let button = ActionSheet.Button.default(Text(language?.capitalized ?? code), action: {
                UserDefaultsManager.shared.language = code
            })
            buttons.append(button)
        }
        let button = ActionSheet.Button.cancel(Text(Localization.cancel))
        buttons.append(button)
        return buttons
    }
    
}
