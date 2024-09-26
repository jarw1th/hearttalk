
import SwiftUI
import YandexMobileAds

@main
struct ProjectApp: App {
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    init() {
        MobileAds.initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .environmentObject(viewModel)
        }
    }
    
}
