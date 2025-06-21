import SwiftUI
import Charts

struct StorageDetail: View {
    let onCloseSheet: (() -> Void)?
    
    var body: some View {
        if onCloseSheet != nil {
            StorageList(onCloseSheet: onCloseSheet)
                .listStyle(DefaultListStyle())
        }
        else {
            StorageList(onCloseSheet: onCloseSheet)
                .listStyle(InsetListStyle())
        }
    }
}


private struct StorageList: View {
    let onCloseSheet: (() -> Void)?
    
    @EnvironmentObject var statusProvider: StatusProvider
    
    var body: some View {
        let data = statusProvider.status?.last
        List {
            if data?.storage != nil {
                ForEach(data!.storage!.indices, id: \.self) { index in
                    let entry = data!.storage![index]
                    Section(entry.name ?? "") {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(storageValue(value: entry.total))
                        }
                        HStack {
                            Text("Used")
                            Spacer()
                            Text(
                                entry.total != nil && entry.available != nil
                                    ? storageValue(value: entry.total! - Double(entry.available!))
                                    : "N/A"
                            )
                        }
                        HStack {
                            Text("Available")
                            Spacer()
                            Text(entry.available != nil ? storageValue(value: Double(entry.available!)) : "N/A")
                        }
                        StorageChart(storageIndex: index)
                    }
                }
            }
        }
        .navigationTitle("Storage")
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

private struct StorageChartData: Equatable {
    let id: String
    let used: Double?
    let total: Double?
    let unit: String?
    
    init(id: String, used: Double?, total: Double?, unit: String?) {
        self.id = id
        self.used = used
        self.total = total
        self.unit = unit
    }
}

private struct StorageChart: View {
    let storageIndex: Int
    
    @EnvironmentObject var statusProvider: StatusProvider
    
    private func generateChartData() -> [StorageChartData]? {
        guard let data = statusProvider.status else { return nil }
        var reversedData: [StatusModel?] = data.reversed()
        if reversedData.count < ChartsConfig.points {
            reversedData.append(contentsOf: Array(repeating: nil, count: ChartsConfig.points-reversedData.count))
        }
        else {
            reversedData = Array(reversedData.prefix(ChartsConfig.points))
        }
        
        guard let last = reversedData.last else { return nil }
        
        let unit = last?.storage?[storageIndex].total != nil
            ? last!.storage![storageIndex].total!/1000000000 > 1000
                ? "TB"
                : "GB"
            : ""
        
        return reversedData.map() {
            return StorageChartData(
                id: UUID().uuidString,
                used: $0?.storage?[storageIndex].total != nil && $0?.storage?[storageIndex].available != nil
                ? (Double($0!.storage![storageIndex].total!) - Double($0!.storage![storageIndex].available!))/(unit == "TB" ? 1000000000000 : 1000000000)
                    : nil,
                total: $0?.storage![storageIndex].total != nil ? Double($0!.storage![storageIndex].total!)/(unit == "TB" ? 1000000000000 : 1000000000) : 0.0,
                unit: unit
            )
        }
    }
    
    @State private var selectedIndex: Int?
    
    var body: some View {
        let chartData = generateChartData()
        let maxValue = chartData?.map() { return $0.total ?? 0 }.max() ?? 0
        if let chartData = chartData {
            Chart(Array(chartData.enumerated()), id: \.element.id) { index, item in
                LineMark(
                    x: .value("", index),
                    y: .value("Storage", (item.used ?? 0))
                )
                .interpolationMethod(.catmullRom)
                AreaMark(
                    x: .value("", index),
                    y: .value("Storage", (item.used ?? 0))
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
                            value: Double(value),
                            index: selectedIndex,
                            type: "Storage",
                            unit: "GB",
                        )
                    }
                }
            }
            .chartXSelection(value: $selectedIndex)
            .chartYScale(domain: 0...maxValue)
            .chartYAxisLabel(LocalizedStringKey("Storage"))
            .chartXAxis(Visibility.hidden)
            .animation(.easeInOut(duration: 0.2), value: chartData)
            .frame(height: 300)
            .padding(.bottom, 16)
            .listRowSeparator(.hidden)
        }
    }
}
