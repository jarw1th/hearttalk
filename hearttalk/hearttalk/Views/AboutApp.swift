
import SwiftUI

struct AboutApp: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShareApp: Bool = false
    @State private var isClearAlert: Bool = false
    @State private var isShowWhatIs: Bool = false
    @State private var isShowPDF: Bool = false
    
    @State private var pdftype: PDFType = .privacy
    
    var body: some View {
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
            .alert(isPresented: $isClearAlert) {
                Alert(title: Text(Localization.deleting), primaryButton: .destructive(Text(Localization.delete), action: {
                    viewModel.clearData()
                }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
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
                    case .clear:
                        clearAction()
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
    
    private func clearAction() {
        isClearAlert.toggle()
    }
    
    private func whatIsAction() {
        isShowWhatIs.toggle()
    }
    
    private func contactAction() {
        let email = "mailto:help.hearttalk@gmail.com"
        if let url = URL(string: email) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Can't open Gmail")
            }
        }
    }
    
    private func termsAction() {
        pdftype = .terms
        isShowPDF.toggle()
    }
    
    private func privacyAction() {
        pdftype = .privacy
        isShowPDF.toggle()
    }
    
}
