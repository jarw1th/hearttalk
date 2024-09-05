
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            
        }
    }
    
    
    
}

#Preview {
    HomeScreen()
}
