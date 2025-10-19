import SwiftUI

struct InstanceFormView: View {
    var instance: ServerInstances?
    var onClose: () -> Void
    
    init(instance: ServerInstances? = nil, onClose: @escaping () -> Void) {
        self.instance = instance
        self.onClose = onClose
    }
    
    @EnvironmentObject private var instanceFormModel: InstanceFormViewModel
    @EnvironmentObject private var instancesModel: InstancesProvider
    @EnvironmentObject private var statusModel: StatusProvider
    
    func instanceUrl() -> String {
        return "\(String(instanceFormModel.connectionMethod).lowercased())://\(instanceFormModel.ipDomain)\(instanceFormModel.port != "" ? ":\(instanceFormModel.port)" : "")\(instanceFormModel.path)"
    }
    
    var body: some View {
        let validValues = instanceFormModel.name != "" && instanceFormModel.ipDomain != "" && instanceFormModel.ipDomainValid && instanceFormModel.portValid && instanceFormModel.pathValid && ((instanceFormModel.useBasicAuth && instanceFormModel.basicAuthUser != "" && instanceFormModel.basicAuthPassword != "") || !instanceFormModel.useBasicAuth)
        let url = instanceUrl()
        NavigationView {
            Form {
                List {
                    Section() {
                        Text(url != "" ? url : "Instance URL")
                            .foregroundColor(url != "" ? .blue : .gray)
                        
                        HStack {
                            Image(systemName: validValues ? "checkmark" : "exclamationmark.circle.fill")
                                .foregroundColor(validValues ? .green : .red)
                            Text(validValues ? "All values are valid" : "Some of the values are missing or invalid")
                                .foregroundColor(validValues ? .green : .red)
                        }
                        
                    }
                    Section("Server details") {
                        TextField("Server name", text: $instanceFormModel.name)
                            .disabled(instanceFormModel.isLoading)
                    }
                    Section("Connection details") {
                        Picker("Connection method", selection: $instanceFormModel.connectionMethod) {
                            Text("HTTP").tag("HTTP")
                            Text("HTTPS").tag("HTTPS")
                        }
                        .disabled(instanceFormModel.isLoading)
                        TextField("IP address or domain", text: $instanceFormModel.ipDomain).keyboardType(.URL)
                            .onChange(of: instanceFormModel.ipDomain) { _, newValue in
                                instanceFormModel.validateIpDomain(value: newValue)
                            }
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disabled(instanceFormModel.isLoading)
                        TextField("Port", text: $instanceFormModel.port).keyboardType(.numberPad)
                            .onChange(of: instanceFormModel.port) { _, newValue in
                                instanceFormModel.validatePort(value: newValue)
                            }
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disabled(instanceFormModel.isLoading)
                        TextField("Path (Example: /path)", text: $instanceFormModel.path).keyboardType(.URL)
                            .onChange(of: instanceFormModel.path) { _, newValue in
                                instanceFormModel.validatePath(value: newValue)
                            }
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disabled(instanceFormModel.isLoading)
                    }
                    Section("Basic authentication") {
                        Toggle(
                            "Use basic authentication",
                            isOn: $instanceFormModel.useBasicAuth
                        ).onChange(of: instanceFormModel.useBasicAuth) {
                            instanceFormModel.toggleBasicAuth()
                        }
                        .disabled(instanceFormModel.isLoading)
                        if instanceFormModel.useBasicAuth == true {
                            TextField("Username", text: $instanceFormModel.basicAuthUser)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .disabled(instanceFormModel.isLoading)
                            SecureField("Password", text: $instanceFormModel.basicAuthPassword)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .disabled(instanceFormModel.isLoading)
                        }
                    }
                }
            }
            .navigationTitle(instanceFormModel.editId != "" ? "Edit instance" : "Create instance")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if instanceFormModel.isLoading == true {
                        ProgressView()
                    }
                    else {
                        Button {
                            if validValues == true {
                                instanceFormModel.saveInstance() {
                                    onClose()
                                }
                            }
                            else {
                                instanceFormModel.fillFieldsError = true
                            }
                        } label: {
                            Text("Save")
                        }
                        .glassProminentButtonStyleIfAvailable()
                    }
                }
            })
            .alert("Error", isPresented: $instanceFormModel.showError) {
                Button {
                    instanceFormModel.showError.toggle()
                } label: {
                    Text("Close")
                }
            } message: {
                    Text(instanceFormModel.error)
            }
            .alert("Fill requierd fields", isPresented: $instanceFormModel.fillFieldsError) {
                
            } message: {
                Text("Fill all the required fields before trying to save")
            }
        }
        .navigationViewStyle(.stack)
        .interactiveDismissDisabled()
    }
}

struct InstanceFormView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceFormView() {
            
        }
    }
}
