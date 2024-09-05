
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
                        .font(.custom("PlayfairDisplay-Regular", size: 20))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.darkWhite)
                    Spacer()
                    Text(properties.text)
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.darkWhite)
                }
            }
            .padding(24)
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
                        .frame(width: 48, height: 48)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
        }
    }
    
    private func makeOpen() -> some View {
        ZStack {
            VStack(spacing: 2) {
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
            isOpened.toggle()
        } label: {
            VStack {
                Image("greenCross")
                    .resizable()
                    .frame(width: 48, height: 48)
            }
        }
    }
    
    private func makePack() -> some View {
        Button {
            tapAction(.pack)
            isOpened.toggle()
        } label: {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(.lightGray)
                    .clipShape(CustomRoundedRectangle(topLeft: 20, topRight: 20))
                
                Text("Create pack")
                    .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkGreen)
                    .padding(.top, 20)
                    .padding(.leading, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 79)
        }
    }
    
    private func makeCard() -> some View {
        Button {
            tapAction(.card)
            isOpened.toggle()
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(.lightGray)
                    .clipShape(CustomRoundedRectangle(bottomLeft: 20, bottomRight: 20))
                
                Text("Create card")
                    .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.darkGreen)
                    .padding(.bottom, 20)
                    .padding(.trailing, 24)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 79)
        }
    }
    
}
