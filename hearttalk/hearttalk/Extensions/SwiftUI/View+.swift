
import UIKit
import SwiftUI
import WidgetKit

extension View {
    
    func asImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let renderer = UIGraphicsImageRenderer(bounds: view?.bounds ?? CGRect.zero)
        return renderer.image { ctx in
            view?.drawHierarchy(in: view?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        }
    }
    
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(watchOS 10.0, iOSApplicationExtension 17.0, iOS 17.0, macOSApplicationExtension 14.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
    
}
