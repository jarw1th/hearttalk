
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
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .foregroundColor(.lightBlack)
                    .opacity(0.66)
            }
            TextField("", text: $text)
                .autocapitalization(.sentences)
                .disableAutocorrection(true)
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
        )
    }
    
}
