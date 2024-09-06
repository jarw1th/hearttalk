
import UIKit

final class HapticManager {
    
    static var shared: HapticManager = HapticManager()
    
    func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
}
