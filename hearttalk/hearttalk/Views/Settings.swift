
import SwiftUI

struct Settings: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isPresented: Bool
    
    @State private var isClearAlert: Bool = false
    @State private var isShowLanguage: Bool = false
    
    @State private var isVibrations: Bool = false
    @State private var isDailyCard: Bool = false
    @State private var isSounds: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                isVibrations = viewModel.isVibrations
                isSounds = viewModel.isSounds
                isDailyCard = viewModel.isDailyCard
            }
            .onChange(of: isVibrations) { new in
                viewModel.isVibrations = new
            }
            .onChange(of: isSounds) { new in
                viewModel.isSounds = new
            }
            .onChange(of: isDailyCard) { new in
                viewModel.isDailyCard = new
            }
            .alert(isPresented: $isClearAlert) {
                Alert(title: Text(Localization.deleting), primaryButton: .destructive(Text(Localization.delete), action: {
                    viewModel.clearData()
                }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
            }
            .actionSheet(isPresented: $isShowLanguage) {
                ActionSheet(
                    title: Text(Localization.languageActionSheetTitle),
                    message: Text(Localization.languageActionSheetMessage),
                    buttons: makeActionSheetButtons()
                )
            }
    }
    
    private func makeContent() -> some View {
        VStack {
            HStack {
                Spacer()
                makeCloseButton()
            }
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
                Text(Localization.settings.capitalized)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                makeList()
                Spacer()
                makeBackButton()
            }
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 10)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makeList() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16) {
            ForEach(Array(SettingsType.allCases.enumerated()), id: \.element) { index, settingsType in
                VStack {
                    switch settingsType {
                    case .vibrations:
                        SettingsToggler(text: settingsType.text(), isOn: $isVibrations)
                    case .sounds:
                        SettingsToggler(text: settingsType.text(), isOn: $isSounds)
                    case .dailyCard:
                        SettingsToggler(text: settingsType.text(), isOn: $isDailyCard)
                    case .language:
                        SettingsListItem(imageName: settingsType.imageName(), text: settingsType.text(), isSpecial: settingsType.isSpecial(), action: languageAction)
                    case .clear:
                        SettingsListItem(imageName: settingsType.imageName(), text: settingsType.text(), isSpecial: settingsType.isSpecial(), action: clearAction)
                    }
                }
            }
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(Localization.goBack)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
    private func makeCloseButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            isPresented.toggle()
        } label: {
            Image("cross")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48)
        }
    }
    
    private func languageAction() {
        isShowLanguage.toggle()
    }
    
    private func clearAction() {
        isClearAlert.toggle()
    }
    
    private func makeActionSheetButtons() -> [ActionSheet.Button]  {
        var buttons: [ActionSheet.Button] = []
        for code in Bundle.main.localizations {
            let language = Locale(identifier: code).localizedString(forLanguageCode: code)
            
            let button = ActionSheet.Button.default(Text(language?.capitalized ?? code), action: {
                viewModel.language = code
            })
            buttons.append(button)
        }
        let button = ActionSheet.Button.cancel(Text(Localization.cancel))
        buttons.append(button)
        return buttons
    }
    
}

#Preview {
    AboutApp()
}
