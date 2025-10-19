import SwiftUI

struct TabletViewHardwareEntry: View {
    let image: String
    let label: String
    let hardwareItem: Enums.HardwareItem
    let value1: String
    let value1Image: String
    let value2: String?
    let value2Image: String?
    
    @EnvironmentObject var statusProvider: StatusProvider
    
    var body: some View {
        let foregroundColor = statusProvider.selectedHardwareItem == hardwareItem
        ? Color.white
        : Color.foreground
        HStack {
            Button {
                withAnimation(nil) {
                    statusProvider.selectedHardwareItem = hardwareItem
                }
            } label: {
                HStack {
                    Image(systemName: image)
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                        .frame(width: 30)
                        .foregroundColor(foregroundColor)
                    Spacer().frame(width: 16)
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey(label))
                            .font(.system(size: 20))
                            .foregroundColor(foregroundColor)
                        Spacer().frame(height: 8)
                        HStack {
                            HStack {
                                Image(systemName: value1Image)
                                    .foregroundColor(foregroundColor)
                                Text(value1)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundColor(foregroundColor)
                            }
                            if value2 != nil && value2Image != nil {
                                Spacer().frame(width: 16)
                                HStack {
                                    Image(systemName: value2Image!)
                                        .foregroundColor(foregroundColor)
                                    Text(value2!)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(foregroundColor)
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
            .toggleGlassButtonIfAvailable(statusProvider.selectedHardwareItem == hardwareItem)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .animation(.default, value: statusProvider.selectedHardwareItem == hardwareItem)
        }
        .cornerRadius(8)
    }
}
