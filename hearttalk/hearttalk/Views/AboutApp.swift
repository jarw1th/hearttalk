
import SwiftUI

struct AboutApp: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShareApp: Bool = false
    @State private var isClearAlert: Bool = false
    @State private var isShowWhatIs: Bool = false
    
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
            VStack(spacing: 24) {
                Text(Localization.aboutTheApp)
                    .font(.custom("PlayfairDisplay-SemiBold", size: 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                makeList()
                makeCridential()
                    .padding(.top, 12)
                Spacer()
                Text("\(Localization.version) \(viewModel.appVersion)")
                    .font(.custom("PlayfairDisplay-Regular", size: 10))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.darkWhite)
                    .opacity(0.66)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 70)
        .padding(.horizontal, 20)
    }
    
    private func makeCridential() -> some View {
        VStack {
            Image("logoIcon")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: 20, height: 18)
                .opacity(0.66)
            Text(Localization.credential)
                .font(.custom("PlayfairDisplay-SemiBold", size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(0.66)
        }
    }
    
    private func makeList() -> some View {
        VStack(spacing: 8) {
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
                    default:
                        print()
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
                .frame(width: 24, height: 24)
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
    
}

#Preview {
    AboutApp()
}
