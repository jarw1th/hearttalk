
import SwiftUI

struct AboutApp: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShareApp: Bool = false
    @State private var isShowSettings: Bool = false
    @State private var isShowWhatIs: Bool = false
    @State private var isShowPDF: Bool = false
    @State private var isShowContacts: Bool = false
    
    @State private var pdftype: PDFType = .privacy
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
                .edgesIgnoringSafeArea(.bottom)
                .sheet(isPresented: $isShareApp) {
                    ActivityViewControllerRepresentableCenter(activityItems: [viewModel.shareApp()])
                }
                .fullScreenCover(isPresented: $isShowWhatIs) {
                    WhatIsTheApp()
                }
                .fullScreenCover(isPresented: $isShowPDF) {
                    PDFScreen(pdfType: pdftype)
                }
                .actionSheet(isPresented: $isShowContacts) {
                    ActionSheet(
                        title: Text(""),
                        buttons: makeActionSheetButtons()
                    )
                }
        }
    }
    
    private func makeContent() -> some View {
        VStack {
            HStack {
                Spacer()
                makeBackButton()
            }
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
                Text(Localization.aboutTheApp)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                makeList()
                makeCridential()
                    .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 12 : 0)
                Spacer()
                if  UIDevice.current.userInterfaceIdiom == .phone {
                    Text("\(Localization.version) \(viewModel.appVersion)")
                        .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 10 : 14))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.darkWhite)
                        .opacity(0.66)
                }
            }
            NavigationLink(
                destination: Settings(isPresented: $isShowSettings)
                    .environmentObject(viewModel)
                    .navigationBarHidden(true),
                isActive: $isShowSettings
            ) {
                EmptyView()
            }
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 10)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makeCridential() -> some View {
        VStack(spacing: 8) {
            Image("logoIcon")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40, height: UIDevice.current.userInterfaceIdiom == .phone ? 18 : 34)
                .opacity(0.66)
            Text(Localization.credential)
                .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(0.66)
        }
    }
    
    private func makeList() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16) {
            ForEach(Array(AboutAppType.allCases.enumerated()), id: \.element) { index, aboutAppType in
                AboutListItem(imageName: aboutAppType.imageName(), text: aboutAppType.text(), isSpecial: aboutAppType.isSpecial()) {
                    switch aboutAppType {
                    case .share:
                        shareAction()
                    case .review:
                        reviewAction()
                    case .settings:
                        settingsAction()
                    case .whatis:
                        whatIsAction()
                    case .contact:
                        contactAction()
                    case .terms:
                        termsAction()
                    case .privacy:
                        privacyAction()
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
            Image("cross")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48)
        }
    }
    
    private func shareAction() {
        isShareApp.toggle()
    }
    
    private func reviewAction() {
        viewModel.requestReview()
    }
    
    private func settingsAction() {
        isShowSettings.toggle()
    }
    
    private func whatIsAction() {
        isShowWhatIs.toggle()
    }
    
    private func contactAction() {
        isShowContacts.toggle()
    }
    
    private func termsAction() {
        pdftype = .terms
        isShowPDF.toggle()
    }
    
    private func privacyAction() {
        pdftype = .privacy
        isShowPDF.toggle()
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
    
}

#Preview {
    AboutApp()
}
