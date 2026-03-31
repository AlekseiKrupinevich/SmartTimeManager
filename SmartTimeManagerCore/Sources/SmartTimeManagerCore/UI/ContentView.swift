import SwiftUI

struct ContentView<DI: DIProtocol>: View {
    var body: some View {
        TabView {
            TasksView<DI>()
                .tabItem {
                    Label("Tasks".localized, systemImage: "list.bullet")
                }
            NotesView<DI>()
                .tabItem {
                    Label("Notes".localized, systemImage: "note.text")
                }
            SettingsView()
                .tabItem { 
                    Label("Settings".localized, systemImage: "gearshape")
                }
        }
    }
}
