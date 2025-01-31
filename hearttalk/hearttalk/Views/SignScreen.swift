
import SwiftUI

struct SignScreen: View {
    
    @EnvironmentObject var viewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var alertType: OnlineAlertType?
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(item: $alertType) { type in
                Alert(title: Text(Localization.onlineAlert), message: Text(type.text), dismissButton: .default(Text(Localization.confirm), action: {}))
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
                    CustomTextField(placeholder: Localization.onlineEmail, text: $email)
                    PasswordTextField(placeholder: Localization.onlinePassword, text: $password)
                    makeResetButton()
                        .frame(maxWidth: .infinity, alignment: .leading)
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
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            if checkEmail() && checkPassword() {
                signAction()
                return
            }
            if !checkEmail() {
                alertType = .password
                return
            }
            if !checkPassword() {
                alertType = .email
                return
            }
        } label: {
            Text(Localization.onlineSignIn)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
    private func makeResetButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            resetAction()
        } label: {
            Text(Localization.onlineResetPass)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.blue)
        }
    }
    
    private func checkPassword() -> Bool {
        if password.count <= 8 {
            return false
        }
        
        let regex = "^(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
    
    private func checkEmail() -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
    
    private func signAction() {
        viewModel.sign(email: email, password: password) { success, isRightPassword in
            guard isRightPassword else {
                alertType = .wrongPassword(email)
                return
            }
            if success {
                dismiss()
            } else {
                alertType = .wrongPassword(email)
            }
        }
    }
    
    private func resetAction() {
        viewModel.resetPassword(email: email) { success in
            if success {
                alertType = .successReset(email)
            } else {
                alertType = .noEmail(email)
            }
        }
    }
    
}
