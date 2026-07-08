import SwiftUI

struct TabletView: View {
    @EnvironmentObject var instancesModel: InstancesProvider
    @EnvironmentObject var statusProvider: StatusProvider
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var scheme
    
    @AppStorage(StorageKeys.showServerUrlDetails, store: UserDefaults.shared) private var showServerUrlDetails: Bool = true
    
    @State var showSystemInfoSheet = false
    @State var showSettingsSheet = false
    
    var body: some View {
        let data = statusProvider.status?.last
        let previous = statusProvider.status != nil ? statusProvider.status!.count > 1 ? statusProvider.status![statusProvider.status!.count-2] : nil : nil
        
        let cpuMaxTemp = data?.cpu?.temperature?.first
        
        func getMemoryValue() -> String {
            guard let total = data?.memory?.total else { return "N/A" }
            guard let available = data?.memory?.available else { return "N/A" }
            let memoryUsed = total - available
            let memoryPerc = (Double(memoryUsed)/Double(total))*100.0
            return "\(Int(memoryPerc))%"
        }
        
        func getStorageValue() -> String {
            let a = data?.storage?.map() { $0.available ?? 0}.max()
            let t = data?.storage?.map() { $0.total ?? 0}.max()
            guard let available = a else { return "N/A" }
            guard let total = t else { return "N/A" }
            let percent = 100.0-((Double(available)/Double(total))*100.0)
            return "\(Int(percent))%"
        }
        
        func getDownloadValue() -> String {
            guard let current = data?.network?.rx else { return "N/A" }
            guard let previous = previous?.network?.rx else { return "N/A" }
            return formatBits(value: abs(current - previous))
        }
        
        func getUploadValue() -> String {
            guard let current = data?.network?.tx else { return "N/A" }
            guard let previous = previous?.network?.tx else { return "N/A" }
            return formatBits(value: abs(current - previous))
        }
        
        return NavigationSplitView(columnVisibility: .constant(.all)) {
            VStack {
                if statusProvider.initialLoading == true {
                    VStack {
                        ProgressView()
                    }
                }
                else if statusProvider.loadError == true {
                    VStack {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 40))
                        Spacer().frame(height: 20)
                        Text("An error occured while loading the data.")
                            .font(.system(size: 24))
                            .multilineTextAlignment(.center)
                        Spacer()
                            .frame(height: 40)
                        Button {
                            Task { await statusProvider.fetchStatus(showLoading: true, showError: true) }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Retry")
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if instancesModel.selectedInstance != nil && showServerUrlDetails {
                                Text(generateInstanceUrl(instance: instancesModel.selectedInstance!))
                                    .padding(.leading, 17)
                                    .padding(.bottom, 10)
                                    .foregroundColor(.gray)
                            }
                            TabletViewHardwareEntry(
                                image: "cpu",
                                label: "CPU",
                                hardwareItem: Enums.HardwareItem.cpu,
                                value1: data?.cpu?.utilisation != nil ? "\(String(describing: Int(data!.cpu!.utilisation!*100)))%" : "N/A",
                                value1Image: "cpu",
                                value2: cpuMaxTemp != nil ? "\(String(describing: cpuMaxTemp!))ºC" : "N/A",
                                value2Image: "thermometer.medium"
                            )
                            TabletViewHardwareEntry(
                                image: "memorychip",
                                label: "Memory",
                                hardwareItem: Enums.HardwareItem.memory,
                                value1: getMemoryValue(),
                                value1Image: "memorychip",
                                value2: nil,
                                value2Image: nil
                            )
                            TabletViewHardwareEntry(
                                image: "internaldrive",
                                label: "Storage",
                                hardwareItem: Enums.HardwareItem.storage,
                                value1: getStorageValue(),
                                value1Image: "internaldrive",
                                value2: nil,
                                value2Image: nil
                            )
                            TabletViewHardwareEntry(
                                image: "network",
                                label: "Network",
                                hardwareItem: Enums.HardwareItem.network,
                                value1: getDownloadValue(),
                                value1Image: "arrow.down.circle",
                                value2: getUploadValue(),
                                value2Image: "arrow.up.circle"
                            )
                        }
                    }
                    .refreshable {
                        await statusProvider.fetchStatus()
                    }
                }
            }
            .navigationTitle(instancesModel.selectedInstance?.name ?? "Server status")
            .toolbar(content: {
                ToolbarItem {
                    HStack {
                        if statusProvider.status?.isEmpty == false && statusProvider.status?[0].host != nil {
                            Button {
                                showSystemInfoSheet.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            .sheet(isPresented: $showSystemInfoSheet, content: {
                                DetailsSheet(hardwareItem: Enums.HardwareItem.systemInfo, onCloseSheet: { showSystemInfoSheet.toggle() })
                            })
                        }
                        if horizontalSizeClass == .regular {
                            Button {
                                showSettingsSheet.toggle()
                            } label: {
                                Image(systemName: "gear")
                            }
                        }
                    }
                }
            })
            .sheet(isPresented: $showSettingsSheet, content: {
                SettingsView(scheme: scheme) {
                    showSettingsSheet.toggle()
                }
            })
        } detail: {
            if statusProvider.status != nil && statusProvider.selectedHardwareItem != nil {
                switch statusProvider.selectedHardwareItem! {
                    case .cpu:
                        CpuDetail(onCloseSheet: nil)
                    case .memory:
                        MemoryDetail(onCloseSheet: nil)
                    case .storage:
                        StorageDetail(onCloseSheet: nil)
                    case .network:
                        NetworkDetail(onCloseSheet: nil)
                    case .systemInfo:
                        SystemDetail(onCloseSheet: nil)
                }
            }
            else {
                VStack {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                    Spacer().frame(height: 20)
                    Text("Select a hardware item to show it's details.")
                        .font(.system(size: 24))
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
