import Foundation
import Combine
import CoreData

@MainActor
class InstanceFormViewModel: ObservableObject {
    @Published var editId = ""
    @Published var name = ""
    @Published var connectionMethod = "HTTP"
    @Published var ipDomain = ""
    @Published var ipDomainValid = true
    @Published var port = ""
    @Published var portValid = true
    @Published var path = ""
    @Published var pathValid = true
    @Published var useBasicAuth = false
    @Published var basicAuthUser = ""
    @Published var basicAuthPassword = ""
    
    @Published var isLoading = false
    
    @Published var showError = false
    @Published var error = ""
    @Published var fillFieldsError = false
    
    init(instance: ServerInstances? = nil) {
        guard let instance = instance else { return }
        editId = instance.id!
        name = instance.name!
        connectionMethod = instance.connectionMethod!.uppercased()
        ipDomain = instance.ipDomain!
        port = instance.port ?? ""
        path = instance.path ?? ""
        useBasicAuth = instance.useBasicAuth
        basicAuthUser = instance.basicAuthUser ?? ""
        basicAuthPassword = instance.basicAuthPassword ?? ""
    }
    
    private let persistenceController = PersistenceController.shared
    
    func reset() {
        editId = ""
        name = ""
        connectionMethod = "HTTP"
        ipDomain = ""
        ipDomainValid = true
        port = ""
        portValid = true
        path = ""
        pathValid = true
        useBasicAuth = false
        basicAuthUser = ""
        basicAuthPassword = ""
    }
    
    func toggleBasicAuth() {
        basicAuthUser = ""
        basicAuthPassword = ""
    }
    
    func validateIpDomain(value: String) {
        let domainValid = NSPredicate(format: "SELF MATCHES %@", Regexps.domain).evaluate(with: value)
        let ipValid = NSPredicate(format: "SELF MATCHES %@", Regexps.ipAddress).evaluate(with: value)
        if domainValid || ipValid {
            ipDomainValid = true
        }
        else {
            ipDomainValid = false
        }
    }
    
    func validatePort(value: String) {
        if value == "" {
            portValid = true
            return
        }
        let parsed = Int(value)
        if parsed == nil {
            portValid = false
            return
        }
        if parsed! <= 65535 {
            portValid = true
        }
        else {
            portValid = false
        }
    }
    
    func validatePath(value: String) {
        if value == "" {
            pathValid = true
            return
        }
        let valid = NSPredicate(format: "SELF MATCHES %@", Regexps.path).evaluate(with: value)
        if valid {
            pathValid = true
        }
        else {
            pathValid = false
        }
    }
    
    func saveInstance(finished: @escaping () -> Void) {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            let baseUrl = "\(String(describing: self.connectionMethod))://\(String(describing: self.ipDomain))\(self.port != "" ? ":\(String(describing: self.port))" : "")\(self.path != "" ? String(describing: self.path) : "")"
            let response = await ApiClient.status(
                baseUrl: baseUrl,
                token: useBasicAuth ? encodeCredentialsBasicAuth(username: basicAuthUser, password: basicAuthPassword) : nil
            )
            DispatchQueue.main.async {
                self.isLoading = false
                if response.successful == true {
                    return
                }
                if response.statusCode == nil {
                    self.error = NSLocalizedString("Cannot reach the server. Check the connection data and make sure to have a valid certificate if you are using HTTPS.", comment: "")
                    self.showError.toggle()
                }
                else if response.statusCode == 401 {
                    self.error = NSLocalizedString("Incorrect basic authentication data.", comment: "")
                    self.showError.toggle()
                }
                else {
                    self.error = NSLocalizedString("Unknown error.", comment: "")
                    self.showError.toggle()
                }
            }
            
            if response.successful == false {
                return
            }
            
            let instanceId = self.editId != "" ? self.editId : UUID().uuidString
            
            if editId != "" {
                InstancesProvider.shared.editInstance(
                    id: editId,
                    name: name,
                    connectionMethod: String(connectionMethod).lowercased(),
                    ipDomain: ipDomain,
                    port: port != "" ? port : nil,
                    path: path != "" ? path : nil,
                    useBasicAuth: useBasicAuth,
                    basicAuthUser: basicAuthUser != "" ? basicAuthUser : nil,
                    basicAuthPassword: basicAuthPassword != "" ? basicAuthPassword : nil
                )
            }
            else {
                _ = InstancesProvider.shared.createInstance(
                    id: instanceId,
                    name: name,
                    connectionMethod: String(connectionMethod).lowercased(),
                    ipDomain: ipDomain,
                    port: port != "" ? port : nil,
                    path: path != "" ? path : nil,
                    useBasicAuth: useBasicAuth,
                    basicAuthUser: basicAuthUser != "" ? basicAuthUser : nil,
                    basicAuthPassword: basicAuthPassword != "" ? basicAuthPassword : nil
                )
            }
            
            finished()
        }
    }
}
