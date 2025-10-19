import Combine
import CoreData
import Foundation

@MainActor
class StatusProvider: ObservableObject {
    static let shared = StatusProvider()
    
    @Published var status: [StatusModel]?
    @Published var initialLoading = true
    @Published var loadError = false
    @Published var timer: Timer?
    @Published var selectedHardwareItem: Enums.HardwareItem?
    
    func reset() {
        self.status = nil
        self.initialLoading = true
        self.loadError = false
        self.timer = nil
        self.selectedHardwareItem = nil
    }
    
    func startTimer(instance: ServerInstances? = nil, interval: String) {
        guard (InstancesProvider.shared.selectedInstance != nil || instance != nil) else { return }
        let instanceId = instance?.objectID
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: Double(interval) ?? 2.0, repeats: true) { timer in
                Task {
                    await self.fetchStatus(instanceId: instanceId, showError: self.status == nil)
                }
            }

            guard let t = self.timer else { return }
            RunLoop.current.add(t, forMode: .common)
        }
    }
    
    func changeInterval(newInterval: String) {
        startTimer(interval: newInterval)
    }
    
    func fetchStatus(instanceId: NSManagedObjectID? = nil, showLoading: Bool = false, showError: Bool = false) async {
        func getInstance() -> ServerInstances? {
            let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
            if instanceId != nil {
                guard let instanceId = instanceId else { return nil }
                return try? backgroundContext.existingObject(with: instanceId) as? ServerInstances
            }
            else if InstancesProvider.shared.selectedInstance?.objectID != nil {
                return InstancesProvider.shared.selectedInstance
            }
            else {
                return nil
            }
        }
        
        guard let instance = getInstance() else { return }
        
        if showLoading == true {
            DispatchQueue.main.async {
                self.initialLoading = true
            }
        }
        
        let response = await ApiClient.status(
            baseUrl: generateInstanceUrl(instance: instance),
            token: instance.useBasicAuth ? encodeCredentialsBasicAuth(username: instance.basicAuthUser!, password: instance.basicAuthPassword!) : nil
        )

        if InstancesProvider.shared.selectedInstance?.id != instance.id {
            return
        }
        
        if response.successful == true && response.data != nil {
            do {
                let jsonDictionary = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any]
                let jsonData = try JSONSerialization.data(withJSONObject: transformStatusJSON(input: jsonDictionary!), options: [])
                let data = try JSONDecoder().decode(StatusModel.self, from: Data(jsonData))
                
                DispatchQueue.main.async {
                    if self.status == nil {
                        self.status = [data]
                    }
                    else {
                        self.status!.append(data)
                    }
                    self.initialLoading = false
                    self.loadError = false
                }
            } catch {
                if showError == true {
                    DispatchQueue.main.async {
                        self.initialLoading = false
                        self.loadError = true
                    }
                }
            }
        }
        else {
            if showError == true {
                DispatchQueue.main.async {
                    self.loadError = true
                }
            }
        }
        
        DispatchQueue.main.async {
            self.initialLoading = false
        }
    }
}
