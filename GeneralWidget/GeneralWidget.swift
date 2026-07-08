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

struct GeneralWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        let cpuMaxTemp = entry.data?.cpu?.temperature?.first
        let cpuMaxTempLimit = entry.data?.cpu?.temperature?.last
        
        let total = entry.data?.storage?.map() { $0.total ?? 0 }.max()
        let available = entry.data?.storage?.map() { $0.available ?? 0 }.max()
        
        if entry.data != nil {
            VStack(alignment: .leading) {
                // CPU
                Group {
                    HStack {
                        Text("CPU")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        Spacer()
                        if entry.data?.cpu?.model != nil {
                            Spacer()
                                .frame(height: 4)
                            Text(entry.data!.cpu!.model!)
                                .font(.system(size: 12))
                        }
                    }
                    Spacer()
                        .frame(height: 12)
                    GeometryReader(content: { geometry in
                        HStack {
                            if entry.data?.cpu?.utilisation != nil {
                                Spacer()
                                Gauge(
                                    value: "\(String(describing: Int(entry.data!.cpu!.utilisation!*100)))%",
                                    percentage: entry.data!.cpu!.utilisation!*100,
                                    icon: Image(systemName: "cpu"),
                                    colors: gaugeColors,
                                    size: geometry.size.height
                                )
                            }
                            Spacer()
                            if cpuMaxTemp != nil {
                                Gauge(
                                    value: "\(String(describing: cpuMaxTemp!))ºC",
                                    percentage: Double((cpuMaxTemp! * cpuMaxTempLimit!)/100),
                                    icon: Image(systemName: "thermometer.medium"),
                                    colors: gaugeColors,
                                    size: geometry.size.height
                                )
                                Spacer()
                            }
                        }
                    })
                }
                
                Spacer()
                    .frame(height: 16)
                
                // MEMORY
                Group {
                    HStack {
                        Text("Memory")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        Spacer()
                        if entry.data?.memory?.total != nil {
                            Spacer()
                                .frame(height: 4)
                            Text("\(String(describing: formatMemoryValue(value: entry.data!.memory!.total))) GB")
                                .font(.system(size: 12))
                        }
                    }
                    Spacer()
                        .frame(height: 12)
                    GeometryReader(content: { geometry in
                        HStack {
                            if entry.data?.memory?.total != nil && entry.data?.memory?.available != nil {
                                let used = entry.data!.memory!.total! - entry.data!.memory!.available!
                                let perc = (Double(used)/Double(entry.data!.memory!.total!))*100.0
                                Spacer()
                                Gauge(
                                    value: "\(Int(perc))%",
                                    percentage: perc,
                                    icon: Image(systemName: "memorychip"),
                                    colors: gaugeColors,
                                    size: geometry.size.height
                                )
                            }
                            Spacer()
                            if entry.data?.memory?.available != nil {
                                VStack(alignment: .center) {
                                    Text("\(String(describing: formatMemoryValue(value: entry.data!.memory!.available))) GB")
                                        .font(.system(size: 12))
                                        .fontWeight(.bold)
                                    Spacer()
                                        .frame(height: 4)
                                    Text("available")
                                        .font(.system(size: 12))
                                }
                                Spacer()
                            }
                        }
                    })
                }
                
                Spacer()
                    .frame(height: 16)
                
                // STORAGE
                Group {
                    HStack {
                        Text("Storage")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        Spacer()
                        if total != nil {
                            Spacer()
                                .frame(height: 4)
                            Text(storageValue(value: total))
                                .font(.system(size: 12))
                        }
                    }
                    Spacer()
                        .frame(height: 12)
                    GeometryReader(content: { geometry in
                        HStack {
                            if available != nil && total != nil {
                                let percent = 100.0-((Double(available!)/Double(total!))*100.0)
                                Spacer()
                                Gauge(
                                    value: "\(Int(percent))%",
                                    percentage: percent,
                                    icon: Image(systemName: "internaldrive"),
                                    colors: gaugeColors,
                                    size: geometry.size.height
                                )
                            }
                            Spacer()
                            if available != nil {
                                VStack(alignment: .center) {
                                    Text(storageValue(value: Double(available!)))
                                        .font(.system(size: 12))
                                        .fontWeight(.bold)
                                    Spacer()
                                        .frame(height: 4)
                                    Text("available")
                                        .font(.system(size: 12))
                                }
                                Spacer()
                            }
                        }
                    })
                }
                
                if entry.configuration.showUpdatedTime == true {
                    HStack {
                        Spacer()
                            .frame(height: 16)
                        Text("Updated at \(Text(entry.date, format: Date.FormatStyle().hour().minute()))")
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                    }
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
}

struct GeneralWidget: Widget {
    let kind: String = "GeneralWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GeneralWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .description("General system status")
        .configurationDisplayName("General status")
        .supportedFamilies([.systemLarge])
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
    GeneralWidget()
} timeline: {
    WidgetEntry(date: .now, configuration: .enabledUpdatedTime, data: mockData())
    WidgetEntry(date: .now, configuration: .disabledUpdatedTime, data: mockData())
}
