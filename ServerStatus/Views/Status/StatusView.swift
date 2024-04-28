import SwiftUI

struct StatusView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @EnvironmentObject var instancesModel: InstancesViewModel
    @EnvironmentObject var statusModel: StatusViewModel
    @EnvironmentObject var appConfig: AppConfigViewModel
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .regular {
                TabletView()
            }
            else {
                MobileView()
            }
        }
        .onAppear(perform: {
            guard let selectedInstance = instancesModel.selectedInstance else { return }
            if statusModel.timer == nil {
                statusModel.startTimer(serverInstance: selectedInstance, interval: appConfig.refreshTime)
            }
        })
    }
}

#Preview {
    StatusView()
}
