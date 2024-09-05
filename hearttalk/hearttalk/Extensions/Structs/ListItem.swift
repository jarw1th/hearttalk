
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
                .foregroundStyle(.lightGray)
            Text(question)
                .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightGray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
        )
    }
    
}
