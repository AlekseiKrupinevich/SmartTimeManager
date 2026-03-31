import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                Toggle("Numbering displayed".localized, isOn: $appState.settings.isNumberingDisplayed)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Settings".localized)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
