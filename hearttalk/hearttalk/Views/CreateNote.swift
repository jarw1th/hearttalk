
import SwiftUI

struct CreateNote: View {
    
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
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
            HStack {
                Spacer()
                makeBackButton()
            }
            makeCard()
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makeCreateButton() -> some View {
        Button {
            if checkText() {
                HapticManager.shared.triggerHapticFeedback(.light)
                createAction()
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            Image("check")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkGreen)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 40, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 40)
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
    
    private func makeCard() -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    makeCreateButton()
                }
                .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
                .padding(.trailing, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
                Spacer()
                
                ZStack(alignment: .center) {
                    if text.isEmpty {
                        Text(Localization.notePlaceholder)
                            .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                            .foregroundColor(.lightBlack)
                            .opacity(0.66)
                    }
                    TextView(text: $text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
                .shadow(color: .shadow, radius: 5)
        )
    }
    
    private func checkText() -> Bool {
        text.count > 10
    }
    
    private func createAction() {
        viewModel.createNote(text: text)
    }
    
}

#Preview {
    CreateScreen(createScreenType: .card)
}
