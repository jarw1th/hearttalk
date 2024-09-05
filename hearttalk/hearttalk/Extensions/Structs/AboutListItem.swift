
import SwiftUI

struct AboutListItem: View {
    
    let imageName: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 24) {
                Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.lightBlack)
                    .frame(width: 24, height: 24)
                Text(text)
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.darkWhite)
            )
        }
    }
    
}
