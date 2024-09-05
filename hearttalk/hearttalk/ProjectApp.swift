
import SwiftUI

@main
struct ProjectApp: App {
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .environmentObject(viewModel)
        }
    }
    
}
