
import SwiftUI

struct AboutApp: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
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
                Text("About the app")
                    .font(.custom("PlayfairDisplay-SemiBold", size: 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity)
                makeList()
                makeCridential()
                    .padding(.top, 12)
                Spacer()
                Text("version \(viewModel.appVersion)")
                    .font(.custom("PlayfairDisplay-Regular", size: 10))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.darkWhite)
                    .opacity(0.66)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 70)
        .padding(.horizontal, 20)
    }
    
    private func makeCridential() -> some View {
        VStack {
            Image("logoIcon")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: 20, height: 18)
                .opacity(0.66)
            Text("Ruslan Parastaev")
                .font(.custom("PlayfairDisplay-SemiBold", size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(0.66)
        }
    }
    
    private func makeList() -> some View {
        VStack(spacing: 8) {
            ForEach(Array(AboutAppType.allCases.enumerated()), id: \.element) { index, aboutAppType in
                AboutListItem(imageName: aboutAppType.imageName(), text: aboutAppType.text()) {
                    
                }
            }
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
    AboutApp()
}
