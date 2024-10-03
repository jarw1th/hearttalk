
import SwiftUI
import YandexMobileAds
import FirebaseCore

@main
struct ProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
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
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                addQuickActions()
            case .inactive:
                break
            case .active:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func addQuickActions() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(type: "AddCard", localizedTitle: Localization.addCard, localizedSubtitle: Localization.addCardSub, icon: UIApplicationShortcutIcon(templateImageName: "plus")),
            UIApplicationShortcutItem(type: "AddPack", localizedTitle: Localization.addPack, localizedSubtitle: Localization.addPackSub, icon: UIApplicationShortcutIcon(templateImageName: "plus"))
        ]
    }
    
}
