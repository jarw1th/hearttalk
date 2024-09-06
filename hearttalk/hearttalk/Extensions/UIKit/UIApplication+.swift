
import UIKit

extension UIApplication {
    
    func endEditing() {
        self.windows.forEach { $0.endEditing(true) }
    }
    
}
