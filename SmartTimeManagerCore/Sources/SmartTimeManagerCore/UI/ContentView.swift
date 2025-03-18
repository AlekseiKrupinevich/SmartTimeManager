import SwiftUI

struct ContentView<DI: DIProtocol>: View {
    var body: some View {
        TabView {
            TasksView<DI>()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
            NotesView<DI>()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
            SettingsView()
                .tabItem { 
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
