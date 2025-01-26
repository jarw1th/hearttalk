
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
        VStack {
            HStack {
                Spacer()
                makeBackButton()
            }
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
                if viewModel.isLoading {
                    Spacer()
                    LoadingView()
                    Spacer()
                } else {
                    Text("Signing")
                        .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.darkWhite)
                        .frame(maxWidth: .infinity)
                    FillField(placeholder: "Email", text: $email)
                    FillField(placeholder: "Password", text: $password)
                    Spacer()
                    makeCreateButton()
                }
            }
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
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
            Text("Sign")
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
            dismiss()
        } label: {
            Image("cross")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48)
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
