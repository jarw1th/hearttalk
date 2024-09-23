
import SwiftUI

struct GenerateScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var requestManager: RequestManager = RequestManager()
    
    @State private var text: String = ""
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
    }
    
    private func makeContent() -> some View {
        VStack {
            HStack {
                Spacer()
                makeBackButton()
            }
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
                Text(Localization.generateNoun)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                FillField(placeholder: Localization.prompt, text: $text)
                Spacer()
                makeGenerateButton()
            }
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makeGenerateButton() -> some View {
        Button {
            if requestManager.checkInternetConnectivity() {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                generateAction()
            }
        } label: {
            Text(Localization.generateAction)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
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
    
    private func generateAction() {
        Task {
            let question = await viewModel.createQuestionAI(prompt: text)
            if question.count > 4 {
                viewModel.createCard(question: question)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}

#Preview {
    GenerateScreen()
}
