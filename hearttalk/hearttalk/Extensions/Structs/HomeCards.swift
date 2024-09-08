
import SwiftUI

struct HomeCardProperties {
    
    let color: Color
    let header: String
    let text: String
    let isAvailable: Bool
    
}

struct HomeCard: View {
    
    let properties: HomeCardProperties
    
    init(_ properties: HomeCardProperties) {
        self.properties = properties
    }
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(properties.color)
            
            if !properties.isAvailable {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.lightGray, lineWidth: 2)
            }
            
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
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
            }
            .padding(UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
    }
    
}

struct AddHomeCard: View {
    
    let tapAction: (CreateScreenType) -> Void
    @State private var isOpened: Bool = false
    
    var body: some View {
        VStack {
            if isOpened {
                makeOpen()
            } else {
                makePlus()
            }
        }
        .animation(.easeInOut, value: isOpened)
    }
    
    private func makePlus() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            isOpened.toggle()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.lightGray, lineWidth: 2)
                
                VStack {
                    Image("plus")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.lightGray)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64, height: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
        }
    }
    
    private func makeOpen() -> some View {
        ZStack {
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 2 : 4) {
                makePack()
                makeCard()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            
            makeCross()
        }
    }
    
    private func makeCross() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            isOpened.toggle()
        } label: {
            VStack {
                Image("greenCross")
                    .resizable()
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64, height: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
            }
        }
    }
    
    private func makePack() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            tapAction(.pack)
            isOpened.toggle()
        } label: {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(.lightGray)
                    .clipShape(CustomRoundedRectangle(topLeft: 20, topRight: 20))
                
                Text(Localization.createPack)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkGreen)
                    .padding(.top, 20)
                    .padding(.leading, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? 79 : 78)
        }
    }
    
    private func makeCard() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            tapAction(.card)
            isOpened.toggle()
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(.lightGray)
                    .clipShape(CustomRoundedRectangle(bottomLeft: 20, bottomRight: 20))
                
                Text(Localization.createCard)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.darkGreen)
                    .padding(.bottom, 20)
                    .padding(.trailing, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.userInterfaceIdiom == .phone ? 79 : 78)
        }
    }
    
}

