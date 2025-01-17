import SwiftUI

struct ContentView<DI: DIProtocol>: View {
    var body: some View {
        TabView {
            TasksView<DI>()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
            Spacer()
                .tabItem {
                    Label("Reports", systemImage: "text.page")
                }
            Spacer()
                .tabItem { 
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
