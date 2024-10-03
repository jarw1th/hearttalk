
import UIKit

class QuickActionsManager: ObservableObject {
    
    static let shared = QuickActionsManager()
    
    @Published var quickAction: QuickAction? = nil

    func handleItem(_ item: UIApplicationShortcutItem) {
        if item.type == "AddCard" {
            quickAction = .addCard
        } else if item.type == "AddPack" {
            quickAction = .addPack
        }
    }
    
}
