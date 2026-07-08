import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), configuration: ConfigurationAppIntent(), data: mockData())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetEntry {
        WidgetEntry(date: Date(), configuration: configuration, data: mockData())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WidgetEntry> {
        let nilEntry = WidgetEntry(date: Date(), configuration: configuration, data: nil)
        
        let nextUpdate = Calendar.current.date(
            byAdding: DateComponents(minute: configuration.refreshTime.value),
            to: Date()
        )!

        let fetchedData = await fetchStatus(serverInstance: configuration.serverInstance.value)
        guard let data = fetchedData else { return
            Timeline(entries: [nilEntry], policy: .after(nextUpdate))
        }
       
        let entry = WidgetEntry(date: Date(), configuration: configuration, data: data)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let data: StatusModel?
}

struct CpuWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        let cpuMaxTemp = entry.data?.cpu?.temperature?.first
        let cpuMaxTempLimit = entry.data?.cpu?.temperature?.last
        
        GeometryReader(content: { geometry in
            let width = geometry.size.width - 16
            VStack(alignment: .leading) {
                Text("CPU")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                if entry.data?.cpu?.model != nil {
                    Spacer()
                        .frame(height: 4)
                    Text(entry.data!.cpu!.model!)
                        .font(.system(size: 12))
                }
                if entry.configuration.showUpdatedTime == true {
                    Spacer()
                        .frame(height: 4)
                    Text("Updated at \(Text(entry.date, format: Date.FormatStyle().hour().minute()))")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray)
                }
                Spacer()
                if entry.data != nil {
                    HStack {
                        if entry.data?.cpu?.utilisation != nil {
                            Gauge(
                                value: "\(String(describing: Int(entry.data!.cpu!.utilisation!*100)))%",
                                percentage: entry.data!.cpu!.utilisation!*100,
                                icon: Image(systemName: "cpu"),
                                colors: gaugeColors,
                                size: width/2
                            )
                        }
                        Spacer()
                        if cpuMaxTemp != nil {
                            Gauge(
                                value: "\(String(describing: cpuMaxTemp!))ºC",
                                percentage: Double((cpuMaxTemp! * cpuMaxTempLimit!)/100),
                                icon: Image(systemName: "thermometer.medium"),
                                colors: gaugeColors,
                                size: width/2
                            )
                        }
                        
                    }
                }
                else {
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 24))
                            Spacer()
                                .frame(height: 4)
                            Text("Cannot update status")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
            }
        })
    }
}

struct CpuWidget: Widget {
    let kind: String = "CpuWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            CpuWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .description("CPU status")
        .configurationDisplayName("CPU")
        .supportedFamilies([.systemSmall])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var enabledUpdatedTime: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.showUpdatedTime = true
        return intent
    }
    
    fileprivate static var disabledUpdatedTime: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.showUpdatedTime = false
        return intent
    }
}

#Preview(as: .systemSmall) {
    CpuWidget()
} timeline: {
    WidgetEntry(date: .now, configuration: .enabledUpdatedTime, data: mockData())
    WidgetEntry(date: .now, configuration: .disabledUpdatedTime, data: mockData())
}
