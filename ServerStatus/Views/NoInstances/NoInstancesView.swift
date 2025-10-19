import SwiftUI

struct NoInstancesView: View {
    init() {}
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var scheme
    
    @State private var showSettingsSheet = false
    @State private var showFormSheet = false
    
    var body: some View {
        VStack {
            Text("No instances available")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Spacer().frame(height: 20)
            Text("Create a new instance to begin.")
                .multilineTextAlignment(.center)
            Spacer().frame(height: 50)
            HStack {
                Button {
                    showFormSheet = true
                } label: {
                    Label {
                        Text("Add instance")
                    } icon: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.white)
                }
                .glassProminentButtonStyleIfAvailable()
                .cornerRadius(50)
                .padding(10)
                Spacer()
                    .frame(width: 20)
                if horizontalSizeClass == .regular {
                    Button {
                        showSettingsSheet.toggle()
                    } label: {
                        Label {
                            Text("Settings")
                                .foregroundColor(.white)
                        } icon: {
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                        }

                    }
                    .glassProminentButtonStyleIfAvailable()
                    .cornerRadius(50)
                    .padding(10)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showFormSheet, content: {
            InstanceFormView() {
                showFormSheet = false
            }
            .environmentObject(InstanceFormViewModel())
        })
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                if horizontalSizeClass == .regular {
                    Button {
                        showSettingsSheet.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet, content: {
            SettingsView(scheme: scheme) {
                showSettingsSheet.toggle()
            }
        })
        .navigationTitle("Server Status")
    }
}

#Preview {
    NoInstancesView()
}
