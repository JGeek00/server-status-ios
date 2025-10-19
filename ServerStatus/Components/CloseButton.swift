import SwiftUI

struct CloseButton: View {
    let onClose: () -> Void
        
    var body: some View {
        if #available(iOS 26.0, *) {
            Button {
                onClose()
            } label: {
                Label("Close", systemImage: "xmark")
            }
        } else {
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.foreground.opacity(0.5))
                    .font(.system(size: 14))
                    .fontWeight(Font.Weight.bold)
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())
        }
    }
}

#Preview {
    CloseButton(onClose: {})
}
