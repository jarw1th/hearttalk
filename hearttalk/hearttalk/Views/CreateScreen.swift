
import SwiftUI

struct CreateScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let createScreenType: CreateScreenType
    @State private var text: String = ""
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
    }
    
    private func makeContent() -> some View {
        VStack {
            HStack {
                Spacer()
                makeBackButton()
            }
            VStack(spacing: 24) {
                Text(createScreenType.header())
                    .font(.custom("PlayfairDisplay-SemiBold", size: 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                FillField(placeholder: createScreenType.placeholder(), text: $text)
                Spacer()
                makeCreateButton()
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 70)
        .padding(.horizontal, 20)
    }
    
    private func makeCreateButton() -> some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Create")
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image("cross")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: 24, height: 24)
        }
    }
    
}

#Preview {
    CreateScreen(createScreenType: .card)
}
