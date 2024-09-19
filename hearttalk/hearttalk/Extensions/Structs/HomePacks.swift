
import SwiftUI

struct HomePack: View {
    
    let properties: HomeCardProperties
    
    init(_ properties: HomeCardProperties) {
        self.properties = properties
    }
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        HStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
            Text(properties.description)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.darkWhite)
                .frame(maxWidth: .infinity, maxHeight: 120)
            makeCard()
        }
    }
    
    private func makeCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(properties.color)
            
            VStack {
                Text(properties.header)
                    .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Spacer()
                Text(properties.text)
                    .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.darkWhite)
            }
            .padding(UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
        }
        .frame(width: 140, height: 160)
    }
    
}
