
import SwiftUI

struct ListItem: View {
    
    let number: Int
    let question: String
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        HStack(alignment: .top, spacing: 24) {
            Text("#\(number)")
                .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightBlack)
            Text(question)
                .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
        )
    }
    
}
