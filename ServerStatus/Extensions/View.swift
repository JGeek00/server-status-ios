import SwiftUI

extension View {
    @ViewBuilder
    func glassProminentButtonStyleIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
    
    @ViewBuilder
    func toggleGlassButtonIfAvailable(_ enabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            if enabled == true {
                self.buttonStyle(.glassProminent)
            }
            else {
                self.buttonStyle(.glass)
            }
        } else {
            if enabled == true {
                self.buttonStyle(.borderedProminent)
            }
            else {
                self.buttonStyle(.bordered)
            }
        }
    }
    
    @ViewBuilder
    func glassEffectIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect()
        } else {
            self
        }
    }

    @ViewBuilder
    func condition<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        transform(self)
    }
}
