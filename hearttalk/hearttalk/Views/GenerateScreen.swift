
import SwiftUI

struct GenerateScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
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
            VStack(spacing: 24) {
                Text("Generate")
                    .font(.custom("PlayfairDisplay-SemiBold", size: 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                FillField(placeholder: "Prompt", text: $text)
                Spacer()
                makeGenerateButton()
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 70)
        .padding(.horizontal, 20)
    }
    
    private func makeGenerateButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            generateAction()
        } label: {
            Text("Generate")
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
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
