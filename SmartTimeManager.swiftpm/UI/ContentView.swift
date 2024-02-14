import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
            Spacer()
                .tabItem { 
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
