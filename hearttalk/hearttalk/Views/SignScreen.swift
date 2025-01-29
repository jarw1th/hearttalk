
import SwiftUI

struct SignScreen: View {
    
    @EnvironmentObject var viewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @Binding var needsToSign: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isShowAlert: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text("Something wrong"), message: Text("Password should have: special symbols, numbers, length is more than 8."), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
            .onDisappear {
                needsToSign = false
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            SingleBackTopBar(text: "Hear Talk") {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    CustomTextField(placeholder: "Email", text: $email)
                    CustomTextField(placeholder: "Password", text: $password)
                }
                Spacer()
                makeCreateButton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    private func makeCreateButton() -> some View {
        Button {
            if checkText() {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                signAction()
            } else {
                isShowAlert.toggle()
            }
        } label: {
            Text("Sign in")
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
    private func checkText() -> Bool {
        if password.count <= 8 {
            return false
        }
        
        if !isValidEmail() {
            return false
        }
        
        let regex = "^(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
    
    private func isValidEmail() -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
    
    private func signAction() {
        viewModel.sign(email: email, password: password) { success in
            if success {
                dismiss()
            } else {
                isShowAlert.toggle()
            }
        }
    }
    
}
