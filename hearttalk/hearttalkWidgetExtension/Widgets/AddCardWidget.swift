
import SwiftUI
import WidgetKit

struct AddCardWidgetWrapper: Widget {
    
    let kind: String = "AddCardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AddCardWidgetProvider()) { entry in
            AddCardWidget(entry: entry)
        }
        .configurationDisplayName("Add card widget")
        .description("You can simply create card from home screen.")
        .supportedFamilies([.systemSmall])
    }
    
}

struct AddCardWidget: View {
    
    var entry: AddCardWidgetEntry

    var body: some View {
        VStack {
            if let link = entry.link {
                Link(destination: link) {
                    VStack {
                        Image("plus")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.darkWhite)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64, height: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
                    }
                    .padding()
                    .background(.darkGreen)
                    .cornerRadius(10)
                }
            } else {
                VStack {
                    Image("plus")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.darkWhite)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64, height: UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
                }
                .padding()
                .background(.darkGreen)
                .cornerRadius(10)
            }
        }
        .widgetBackground(Color.darkGreen)
    }
    
}

struct AddCardWidgetEntry: TimelineEntry {
    
    var date: Date
    let link: URL?
    
}

struct AddCardWidgetProvider: TimelineProvider {
    
    typealias Entry = AddCardWidgetEntry

    func placeholder(in context: Context) -> AddCardWidgetEntry {
        AddCardWidgetEntry(date: Date(), link: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (AddCardWidgetEntry) -> Void) {
        let entry = AddCardWidgetEntry(date: Date(), link: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AddCardWidgetEntry>) -> Void) {
        var entries: [AddCardWidgetEntry] = []

        let currentDate = Date()
        let entry = AddCardWidgetEntry(date: currentDate, link: URL(string: "hearttalk://createScreen"))
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
}
