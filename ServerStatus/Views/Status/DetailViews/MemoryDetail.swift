import SwiftUI
import Charts

struct MemoryDetail: View {
    let onCloseSheet: (() -> Void)?
    
    var body: some View {
        if onCloseSheet != nil {
            MemoryList(onCloseSheet: onCloseSheet)
                .listStyle(DefaultListStyle())
        }
        else {
            MemoryList(onCloseSheet: onCloseSheet)
                .listStyle(InsetListStyle())
        }
    }
}

private struct MemoryList: View {
    let onCloseSheet: (() -> Void)?
    
    @EnvironmentObject var statusProvider: StatusProvider
    
    var body: some View {
        let data = statusProvider.status?.last
        List {
            Section("General status") {
                HStack {
                    Text("Total")
                    Spacer()
                    Text("\(formatMemoryValue(value: data?.memory?.total)) GB")
                }
                HStack {
                    Text("Used")
                    Spacer()
                    Text("""
                        \(data?.memory?.total != nil && data?.memory?.available != nil
                            ? formatMemoryValue(value: data!.memory!.total! - data!.memory!.available!)
                            : "N/A") GB
                    """)
                }
                HStack {
                    Text("Available")
                    Spacer()
                    Text("\(formatMemoryValue(value: data?.memory?.available)) GB")
                }
                HStack {
                    Text("Cached")
                    Spacer()
                    Text("\(formatMemoryValue(value: data?.memory?.cached)) GB")
                }
                HStack {
                    Text("Swap total")
                    Spacer()
                    Text("\(formatMemoryValue(value: data?.memory?.swapTotal)) GB")
                } 
                HStack {
                    Text("Swap available")
                    Spacer()
                    Text("\(formatMemoryValue(value: data?.memory?.swapAvailable)) GB")
                }
            }
            MemoryChart()
        }
        .navigationTitle("Memory (RAM)")
        .background(Color.foreground)
        .toolbar {
            if onCloseSheet != nil {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(onClose: {
                        onCloseSheet!()
                    })
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await statusProvider.fetchStatus() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

private struct MemoryChartData: Equatable {
    let id: String
    let used: Int?
    let total: Int?
    
    init(id: String, used: Int?, total: Int?) {
        self.id = id
        self.used = used
        self.total = total
    }
}

private struct MemoryChart: View {
    @EnvironmentObject var statusProvider: StatusProvider
    
    private func generateChartData() -> [MemoryChartData]? {
        guard let data = statusProvider.status else { return nil }
        var reversedData: [StatusModel?] = data.reversed()
        if reversedData.count < ChartsConfig.points {
            reversedData.append(contentsOf: Array(repeating: nil, count: ChartsConfig.points-reversedData.count))
        }
        else {
            reversedData = Array(reversedData.prefix(ChartsConfig.points))
        }
        
        return reversedData.map() {
            return MemoryChartData(
                id: UUID().uuidString,
                used: $0?.memory?.total != nil && $0?.memory?.available != nil
                ? $0!.memory!.total! - $0!.memory!.available!
                : nil,
                total: $0?.memory?.total
            )
        }
    }
    
    @State private var selectedIndex: Int?
    
    var body: some View {
        let chartData = generateChartData()
        let maxValue = chartData?.map() { return $0.total ?? 0 }.max() ?? 0
        if let chartData = chartData {
            Section("Chart") {
                Chart(Array(chartData.enumerated()), id: \.element.id) { index, item in
                    LineMark(
                        x: .value("", index),
                        y: .value("Memory", item.used != nil ? Double(item.used!)/1048576.0 : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    AreaMark(
                        x: .value("", index),
                        y: .value("Memory", item.used != nil ? Double(item.used!)/1048576.0 : 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .blue.opacity(0.5),
                                .blue.opacity(0.2),
                                .blue.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    if let selectedIndex, selectedIndex >= 0 && selectedIndex < chartData.count {
                        let markValue = chartData[selectedIndex]
                        if let value = markValue.used {
                            ChartRuleMark(
                                value: Double(value)/1048576.0,
                                index: selectedIndex,
                                type: "Memory",
                                unit: "GB",
                            )
                        }
                    }
                }
                .chartXSelection(value: $selectedIndex)
                .chartYScale(domain: 0...(Double(maxValue)/1048576.0))
                .chartYAxisLabel(LocalizedStringKey("Memory (GB)"))
                .chartXAxis(Visibility.hidden)
                .animation(.easeInOut(duration: 0.2), value: chartData)
                .frame(height: 300)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .listRowSeparator(.hidden)
            }
        }
    }
}
