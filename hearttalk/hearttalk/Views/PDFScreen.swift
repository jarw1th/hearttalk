
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
        VStack(spacing: 24) {
            NavigationBar(buttonContent: {}, buttonAction: nil)
            
            if let url = pdfType.url() {
                PDFViewer(url: url)
            } else {
                Spacer()
            }
            
            makeBackButton()
        }
        .padding(.top, 8)
        .padding(.bottom, 70)
        .padding(.horizontal, 20)
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(Localization.goBack)
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
}
