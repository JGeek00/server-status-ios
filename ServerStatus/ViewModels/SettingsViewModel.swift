import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var modalOpen = false
    @Published var statusRepoSafariOpen = false
    @Published var aboutThisAppSafariOpen = false
    @Published var myOtherAppsSafariOpen = false
}
