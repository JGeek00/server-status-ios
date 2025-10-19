import SwiftUI

struct DetailedViewButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(LocalizedStringKey("DETAILS"))
                .font(.system(size: 12))
                .fontWeight(.bold)
        }
        .glassProminentButtonStyleIfAvailable()
        .cornerRadius(20)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

#Preview {
    DetailedViewButton(onTap: {})
}
