import SwiftUI
import SafariServices

struct SettingsView: View {
    var scheme: ColorScheme
    var onCloseSheet: (() -> Void)?
    
    @EnvironmentObject var instancesModel: InstancesViewModel
    @StateObject var settingsModel = SettingsViewModel()
    @StateObject var instanceFormModel = InstanceFormViewModel()
    @EnvironmentObject var statusModel: StatusViewModel
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    @AppStorage(StorageKeys.showServerUrlDetails, store: UserDefaults.shared) private var showServerUrlDetails: Bool = true
    @AppStorage(StorageKeys.refreshTime, store: UserDefaults.shared) private var refreshTime: String = "2"
    
    init(scheme: ColorScheme, onCloseSheet: (() -> Void)?) {
        self.scheme = scheme
        self.onCloseSheet = onCloseSheet
    }
    
    var body: some View {
        let valueColor = theme == .dark ? Color(red: 129/255, green: 129/255, blue: 134/255) : Color(red: 138/255 , green: 138/255, blue: 142/255)
        NavigationStack {
            Group {
                List {
                    ServersInstancesList(instanceFormModel: instanceFormModel, settingsModel: settingsModel)
                    Picker("Theme", selection: $theme) {
                        HStack {
                            Image(systemName: "iphone")
                                .padding(.trailing, 6)
                            Text("System defined")
                        }
                        .tag(Enums.Theme.system)
                        HStack {
                            Image(systemName: "sun.max")
                                .padding(.trailing, 6)
                            Text("Light")
                        }
                        .tag(Enums.Theme.light)
                        HStack {
                            Image(systemName: "moon")
                                .padding(.trailing, 6)
                            Text("Dark")
                        }
                        .tag(Enums.Theme.dark)
                    }
                    .pickerStyle(InlinePickerStyle())
                    Section("App settings") {
                        Toggle("Show server URL on details screen", isOn: $showServerUrlDetails)
                        Picker(selection: $refreshTime) {
                            Text("1 second").tag("1")
                            Text("2 seconds").tag("2")
                            Text("5 seconds").tag("5")
                            Text("10 seconds").tag("10")
                        } label: {
                            Text("Refresh time")
                        }
                        .onChange(of: refreshTime) { _, newValue in
                            statusModel.changeInterval(instance: instancesModel.selectedInstance, newInterval: newValue)
                        }
                    }
                    Section("Status API") {
                        Button {
                            settingsModel.statusRepoSafariOpen.toggle()
                        } label: {
                            HStack {
                                Text("Check \"Status\" repository")
                                    .foregroundColor(.foreground)
                                Spacer()
                                Image(systemName: "link")
                                    .foregroundColor(valueColor)
                            }
                        }
                    }
                    Section {
                        NavigationLink("Give a tip to the developer", value: Routes.SettingsRoutes.tips)
                        Button {
                            settingsModel.contactDeveloperSafariOpen.toggle()
                        } label: {
                            HStack {
                                Text("Contact the developer")
                                    .foregroundColor(.foreground)
                                Spacer()
                                Image(systemName: "link")
                                    .foregroundColor(valueColor)
                            }
                        }
                        HStack {
                            Text("App version")
                            Spacer()
                            Text(
                                Bundle.main.infoDictionary?["CFBundleShortVersionString"] != nil
                                ? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                                : "Unknown"
                            )
                            .foregroundColor(valueColor)
                        }
                    } header: {
                        Text("About the app")
                    } footer: {
                        HStack {
                            Spacer()
                            Text("Created on 🇪🇸 by JGeek00")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 16))
                            Spacer()
                        }
                        .padding(.top, 8)
                    }

                }
                .navigationTitle("Settings")
                .toolbar {
                    if onCloseSheet != nil {
                        ToolbarItem(placement: .topBarLeading) {
                            CloseButton {
                                onCloseSheet!()
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Routes.SettingsRoutes.self) { item in
                switch item {
                    case .tips:
                        TipsView()
                }
            }
        }
        .preferredColorScheme(getColorScheme(theme: theme))
        .fullScreenCover(isPresented: $settingsModel.statusRepoSafariOpen, content: {
            SFSafariViewWrapper(url: URL(string: Urls.statusRepo)!).ignoresSafeArea()
        })
        .fullScreenCover(isPresented: $settingsModel.contactDeveloperSafariOpen, content: {
            SFSafariViewWrapper(url: URL(string: Urls.appSupport)!).ignoresSafeArea()
        })
        .sheet(isPresented: $instanceFormModel.modalOpen, content: {
            InstanceFormView(instanceFormModel: instanceFormModel)
        })
        .alert("Delete instance", isPresented:$settingsModel.confirmDeleteOpen, actions: {
            Button(role: .destructive) {
                instancesModel.deleteInstance(
                    instance: settingsModel.selectedItemDelete!,
                    instancesModel: instancesModel,
                    statusModel: statusModel
                )
                settingsModel.selectedItemDelete = nil
            } label: {
                Text("Delete")
            }
        }, message: {
            Text("Are you sure you want to delete this instance?")
        })
        .environment(\.colorScheme, scheme)
    }
}
