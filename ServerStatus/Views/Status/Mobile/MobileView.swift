import SwiftUI

struct MobileView: View {
    @EnvironmentObject var instancesModel: InstancesViewModel
    @EnvironmentObject var appConfig: AppConfigViewModel
    @StateObject var settingsModel = SettingsViewModel()
    @EnvironmentObject var statusModel: StatusViewModel
    
    var body: some View {
        let width =  UIScreen.main.bounds.width - 32
        let gaugeSize = (UIScreen.main.bounds.width*0.5)/2
        VStack {
            if statusModel.initialLoading == true {
                VStack {
                    ProgressView()
                }
            }
            else if statusModel.loadError == true {
                VStack {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 40))
                    Spacer().frame(height: 20)
                    Text("An error occured while loading the data.")
                        .font(.system(size: 24))
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 40)
                    Button {
                        guard let selectedInstance = instancesModel.selectedInstance else { return }
                        Task { await statusModel.fetchStatus(serverInstance: selectedInstance, showError: true) }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retry")
                        }
                    }
                }.padding(.horizontal, 24)
            }
            else {
                ScrollView {
                    VStack(alignment: .leading) {
                        if instancesModel.demoMode == true {
                            Text("Demo mode")
                                .padding(.leading, 8)
                                .foregroundColor(.gray)
                        }
                        if instancesModel.demoMode == false && instancesModel.selectedInstance != nil && appConfig.showUrlDetailsScreen {
                            Text(generateInstanceUrl(instance: instancesModel.selectedInstance!))
                                .padding(.leading, 8)
                                .foregroundColor(.gray)
                        }
                        Spacer().frame(height: 24)
                        CpuData(gaugeSize: gaugeSize)
                        Spacer().frame(height: 24)
                        Divider()
                        Spacer().frame(height: 24)
                        RamData(
                            gaugeSize: gaugeSize,
                            containerWidth: width
                        )
                        Spacer().frame(height: 24)
                        Divider()
                        Spacer().frame(height: 24)
                        StorageData(
                            gaugeSize: gaugeSize,
                            containerWidth: width
                        )
                        Spacer().frame(height: 24)
                        Divider()
                        Spacer().frame(height: 24)
                        NetworkData()
                        Spacer().frame(height: 24)
                    }
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    guard let selectedInstance = instancesModel.selectedInstance else { return }
                    await statusModel.fetchStatus(
                        serverInstance: selectedInstance,
                        showError: false
                    )
                }
            }
        }
        .navigationTitle(instancesModel.selectedInstance?.name ?? "Server status")
        .toolbar(content: {
            ToolbarItem {
                Button {
                    settingsModel.modalOpen.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
        })
        .sheet(isPresented: $settingsModel.modalOpen, content: {
            SettingsView(settingsModel: settingsModel)
        })
    }
}
