import SwiftUI

@main
struct ServerStatusApp: App {    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.locale, .init(identifier: Locale.current.identifier))
                .environmentObject(InstancesProvider.shared)
                .environmentObject(StatusProvider.shared)
                .environmentObject(WelcomeSheetViewModel())
                .environmentObject(IAPManager())
        }
    }
}
