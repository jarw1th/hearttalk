
import SwiftUI

struct FillField: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundColor(.lightBlack)
                    .opacity(0.66)
            }
            TextField("", text: $text)
                .autocapitalization(.sentences)
                .disableAutocorrection(true)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
        )
    }
    
}
