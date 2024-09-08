
import SwiftUI

struct PDFScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let pdfType: PDFType
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
    }
    
    private func makeContent() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
            NavigationBar(buttonContent: {}, buttonAction: nil)
            
            if let url = pdfType.url() {
                PDFViewer(url: url)
            } else {
                Spacer()
            }
            
            makeBackButton()
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
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
    
}
