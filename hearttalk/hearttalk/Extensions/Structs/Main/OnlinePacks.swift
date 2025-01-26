
import SwiftUI

struct OnlinePackProperties {
    
    let color: Color
    let header: String
    let description: String?
    
    init(color: Color, header: String, description: String? = nil) {
        self.color = color
        self.header = header
        self.description = description
    }
    
}

struct OnlinePack: View {
    
    let properties: OnlinePackProperties
    
    init(_ properties: OnlinePackProperties) {
        self.properties = properties
    }
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        HStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
            Text(properties.description ?? "")
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.darkWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 20)
            makeCard()
        }
    }
    
    private func makeCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(properties.color)
            
            VStack(alignment: .leading) {
                Text(properties.header)
                    .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
            }
            .padding(UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
            .frame(alignment: .leading)
        }
        .frame(width: 140)
    }
    
}
