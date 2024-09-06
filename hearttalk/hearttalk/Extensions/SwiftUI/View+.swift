
import UIKit
import SwiftUI

extension View {
    
    func asImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let renderer = UIGraphicsImageRenderer(bounds: view?.bounds ?? CGRect.zero)
        return renderer.image { ctx in
            view?.drawHierarchy(in: view?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        }
    }
    
}
