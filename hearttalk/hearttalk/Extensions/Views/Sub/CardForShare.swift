
import UIKit
import SwiftUI

struct CardForShare: View {
    
    let question: String

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text(question)
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .frame(width: 300, height: 600)
            
            VStack {
                Text("Heart Talk")
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                Spacer()
            }
            .padding(.top, 24)
            .frame(width: 300, height: 600)
        }
        .frame(width: 300, height: 600)
        .background(
            Rectangle()
                .fill(.darkWhite)
        )
        .ignoresSafeArea()
    }
    
}
