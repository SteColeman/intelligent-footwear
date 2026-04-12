import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(session)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            FootwearListView()
                .environmentObject(session)
                .tabItem {
                    Label("Footwear", systemImage: "shoeprints.fill")
                }

            AssignView()
                .environmentObject(session)
                .tabItem {
                    Label("Assign", systemImage: "checkmark.circle")
                }

            InsightsView()
                .environmentObject(session)
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }

            SettingsView()
                .environmentObject(session)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
