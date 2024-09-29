
import UIKit
import SwiftUI

struct CardForShare: View {
    
    let question: String

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text(question)
                    .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, 48)
                Spacer()
            }
            
            VStack {
                Text("Heart Talk")
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .opacity(66)
                Spacer()
            }
            .padding(.top, 24)
        }
        .frame(width: 300, height: 600)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
        )
    }
    
}
