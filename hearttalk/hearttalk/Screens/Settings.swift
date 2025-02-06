
import SwiftUI

struct Settings: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isClearAlert: Bool = false
    @State private var link: String?
    @State private var isShowCredential: Bool = false
    @State private var actionSheetType: SettingsActionSheetType?
    
    @State private var isVibrations: Bool = false
    @State private var isDailyCard: Bool = false
    @State private var isSounds: Bool = false
    @State private var isAutoRead: Bool = false
    
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
                .onAppear {
                    isVibrations = UserDefaultsManager.shared.isVibrations
                    isSounds = UserDefaultsManager.shared.isSounds
                    isDailyCard = UserDefaultsManager.shared.isDailyCard
                    isAutoRead = UserDefaultsManager.shared.isReadCard
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
                .onChange(of: isAutoRead) { new in
                    UserDefaultsManager.shared.isReadCard = new
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
                .fullScreenCover(isPresented: $isShowCredential) {
                    Credential()
                }
        }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            TopBar(text: TabType.settings.text)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
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
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func makeButtonsList() -> some View {
        VStack(spacing: 16) {
            SettingsButton(text: Localization.terms) {
                if UserDefaultsManager.shared.language == "ru" {
                    link = "https://drive.google.com/file/d/1ogo_AsA-0DK2veoZy6j0ZIPxXRMbJq52/view"
                } else {
                    link = "https://drive.google.com/file/d/1LLjh1Akl6LjIpD131I05bfgUe2G6mkYH/view"
                }
            }
            SettingsButton(text: Localization.policy) {
                if UserDefaultsManager.shared.language == "ru" {
                    link = "https://drive.google.com/file/d/1wA2i3IqmI1YKXJq2qJ_FFVqJKAR0wor8/view"
                } else {
                    link = "https://drive.google.com/file/d/1XXEh5408JNOBsV-3UGG_1x48o9lwu_6v/view"
                }
            }
            SettingsButton(text: Localization.contacts) {
                actionSheetType = .contacts
            }
            SettingsButton(text: "Credential") {
                isShowCredential.toggle()
            }
        }
    }
    
    @ViewBuilder
    private func makeSettingsList() -> some View {
        VStack(spacing: 16) {
            SettingsToggle(text: Localization.vibrations, isOn: $isVibrations)
            SettingsToggle(text: Localization.sounds, isOn: $isSounds)
            SettingsToggle(text: "Auto-read card questions", isOn: $isAutoRead)
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
