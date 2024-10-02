
import SwiftUI
import YandexMobileAds
import FirebaseCore

@main
struct ProjectApp: App {
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    init() {
        FirebaseApp.configure()
        MobileAds.initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .environmentObject(viewModel)
        }
    }
    
}
