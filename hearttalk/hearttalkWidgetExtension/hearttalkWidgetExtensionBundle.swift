
import WidgetKit
import SwiftUI

@main
struct hearttalkWidgetExtensionBundle: WidgetBundle {
    
    var body: some Widget {
        AddCardWidgetWrapper()
        DailyCardWidgetWrapper()
    }
    
}
