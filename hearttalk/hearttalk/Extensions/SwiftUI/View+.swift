
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
    
    @ViewBuilder
    func applyScrollIndicators(_ visibilyty: Bool, axes: Axis.Set) -> some View {
        if #available(iOS 16.0, *) {
            self.scrollIndicators(visibilyty ? .visible : .never, axes: axes)
        } else {
            self
        }
    }
    
}
