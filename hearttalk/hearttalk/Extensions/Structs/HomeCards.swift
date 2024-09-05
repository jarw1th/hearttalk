
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

    let tapAction: () -> Void
    
    init(_ tapAction: @escaping () -> Void) {
        self.tapAction = tapAction
    }
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        Button {
            tapAction()
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
    
}
