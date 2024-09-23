
import UIKit

final class HapticManager {
    
    static var shared: HapticManager = HapticManager()
    
    func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if UserDefaults.standard.object(forKey: "isSounds") == nil || UserDefaults.standard.bool(forKey: "isVibrations") == true {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
}
