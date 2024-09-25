
import SwiftUI
import WidgetKit

struct DailyCardWidgetWrapper: Widget {
    
    let kind: String = "DailyCardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyCardWidgetProvider()) { entry in
            DailyCardWidget(entry: entry)
        }
        .configurationDisplayName("Daily card widget")
        .description("Every day we send you random question.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
    
}

struct DailyCardWidget: View {
    
    var entry: DailyCardWidgetEntry

    var body: some View {
        VStack {
            if let link = entry.link {
                Link(destination: link) {
                    VStack {
                        Text(entry.text)
                            .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20))
                            .foregroundColor(.lightBlack)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(.darkWhite)
                    .cornerRadius(10)
                }
            } else {
                VStack {
                    Text(entry.text)
                        .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20))
                        .foregroundColor(.lightBlack)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(.darkWhite)
                .cornerRadius(10)
            }
        }
        .widgetBackground(Color.darkWhite)
    }
    
}

struct DailyCardWidgetEntry: TimelineEntry {
    
    var date: Date
    var text: String
    let link: URL?
    
}

struct DailyCardWidgetProvider: TimelineProvider {
    
    typealias Entry = DailyCardWidgetEntry
    
    private var realmManager: RealmManager = RealmManager()

    func placeholder(in context: Context) -> DailyCardWidgetEntry {
        DailyCardWidgetEntry(date: Date(), text: "Who are you?", link: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyCardWidgetEntry) -> Void) {
        let entry = DailyCardWidgetEntry(date: Date(), text: "Who are you?", link: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyCardWidgetEntry>) -> Void) {
        var entries: [DailyCardWidgetEntry] = []

        let today = Calendar.current.startOfDay(for: Date())
                
        let dailyCardsList = realmManager.fetch(DailyCard.self)
        let dailyCards = Array(dailyCardsList)
        
        print("Widget DailyCards:", Array(dailyCardsList))
        print(dailyCards)

        if let dailyCard = dailyCards.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            let entry = DailyCardWidgetEntry(date: Date(), text: dailyCard.question, link: URL(string: "hearttalk://dailyWidgetOpen"))
            entries.append(entry)
        } else {
            let entry = DailyCardWidgetEntry(date: Date(), text: "No card today", link: nil)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
}
