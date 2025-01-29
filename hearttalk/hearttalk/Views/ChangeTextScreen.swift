
import SwiftUI

struct ChangeTextScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var text: String
    @State private var value: String = ""
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            SingleBackTopBar(text: "Chage text") {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 24) {
                CustomTextField(placeholder: "Value", text: $value)
                Spacer()
                makeCreateButton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    @ViewBuilder
    private func makeCreateButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            text = value
            dismiss()
        } label: {
            Text("Change")
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
}
