import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var dcodeModel: DCodeModel
    @State var selectedTab: Int = 0
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.theme.adaptiveBackground)
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    var body: some View {
        NavigationStack{
            TabView(selection: $selectedTab) {
                ScanTab()
                    .tabItem {
                        Label(Constants.scan, systemImage: Images.qrcodeViewfinder)
                    }
                    .tag(0)
                DiscoveriesTab()
                    .tabItem {
                        Label(Constants.discoveries, systemImage: Images.photoOnRectangle)
                    }
                    .tag(1)
                ProfileTab()
                    .tabItem {
                        Label(Constants.profile, systemImage: Images.person)
                    }
                    .tag(2)
            }
            .accentColor(Colors.adaptiveColor)
            .onChange(of: dcodeModel.incomingUrlFromAppClip) { newValue in
                if let _ = newValue {
                    selectedTab = 0
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
}
