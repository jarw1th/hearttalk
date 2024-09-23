
import SwiftUI

struct CreateScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let createScreenType: CreateScreenType
    @State private var text: String = ""
    @State private var description: String = ""
    @State private var color: Color = Color(hex: "#9CAFB7")
    
    @State private var isShowActionSheet: Bool = false
    
    private let colors: [Color] = [Color(hex: "#9CAFB7"), Color(hex: "#ce796b"), Color(hex: "#e6b89c"), Color(hex: "#ead2ac"), Color(hex: "#8d8d92"), Color(hex: "#4281a4"), Color(hex: "#6b9080"), Color(hex: "#f6ca83"), Color(hex: "#63474d"), Color(hex: "#c57b57")]
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .actionSheet(isPresented: $isShowActionSheet) {
                ActionSheet(
                    title: Text(Localization.packActionSheetTitle),
                    message: Text(Localization.packActionSheetMessage),
                    buttons: makeActionSheetButtons()
                )
            }
    }
    
    private func makeContent() -> some View {
        VStack {
            HStack {
                Spacer()
                makeBackButton()
            }
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
                Text(createScreenType.header())
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                FillField(placeholder: createScreenType.placeholder(), text: $text)
                if createScreenType == .pack {
                    FillField(placeholder: Localization.description, text: $description)
                    ColorPicker(colors: colors, color: $color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    makePackButton()
                }
                Spacer()
                makeCreateButton()
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
                createAction()
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            Text(Localization.create)
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
    
    private func makePackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            isShowActionSheet.toggle()
        } label: {
            HStack {
                Text("\(Localization.to) \(viewModel.selectedSavingType?.name ?? "")")
                    .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.darkWhite)
            )
        }
    }
    
    private func makeActionSheetButtons() -> [ActionSheet.Button]  {
        var buttons: [ActionSheet.Button] = []
        for myCardType in viewModel.myCardTypes {
            let button = ActionSheet.Button.default(Text(myCardType.name), action: {
                viewModel.selectedSavingType = myCardType
            })
            buttons.append(button)
        }
        return buttons
    }
    
    private func checkText() -> Bool {
        switch createScreenType {
        case .pack:
            text.count > 4
        case .card:
            text.count > 10
        }
    }
    
    private func createAction() {
        switch createScreenType {
        case .pack:
            viewModel.createType(name: text, color: color.hex() ?? "", description: description.isEmpty ? Localization.descriptionPlaceholder : description, cardQuestions: [])
        case .card:
            viewModel.createCard(question: text)
        }
    }
    
}

#Preview {
    CreateScreen(createScreenType: .card)
}
