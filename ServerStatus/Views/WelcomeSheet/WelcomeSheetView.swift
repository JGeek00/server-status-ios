import SwiftUI

struct WelcomeSheetView: View {
    init() {}
    
    @EnvironmentObject private var welcomeSheetViewModel: WelcomeSheetViewModel
    
    var body: some View {
        GeometryReader(content: { geometry in
            NavigationStack {
                ZStack(alignment: .bottom) {
                    ScrollView {
                        Spacer().frame(height: 16)
                        Image("icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 0)
                            .padding(24)
                        VStack {
                            Text("Server Status")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer().frame(height: 48)
                            Text(
                                "Server Status is a client for Status, a server monitoring tool. In order to use this application, you must have Stauts deployed on your server."
                            )
                            .multilineTextAlignment(.center)
                            Spacer().frame(height: 16)
                            Text(
                                "You still don't have it? Tap on the following button to check the deployment instructions."
                            )
                            .multilineTextAlignment(.center)
                            Spacer().frame(height: 16)
                            Link(
                                "Status deployment instructions",
                                destination: URL(string: Urls.statusInstallation)!
                            )
                            Spacer().frame(height: 126)
                        }
                        .padding(.horizontal, 24)
                    }
                    ZStack {
                        Group {
                            Text("")
                                .opacity(0)
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.safeAreaInsets.bottom + 80
                        )
                        .background(.ultraThinMaterial)
                        Button {
                            welcomeSheetViewModel.dismissSheet()
                        } label: {
                            Text("Get started")
                                .foregroundColor(Color.white)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .glassProminentButtonStyleIfAvailable()
                        .padding(.bottom, geometry.safeAreaInsets.bottom/2)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled()
            }
        })
    }
}

#Preview {
    WelcomeSheetView()
}
