import SwiftUI

@main
struct SmartTimeManager: App {
    private typealias DI = MockDI
    
    @StateObject private var diContainer: DIContainer<DI> = DIBuilder.build()
    
    var body: some Scene {
        WindowGroup {
            ContentView<DI>()
                .environmentObject(diContainer.appState)
                .environmentObject(diContainer.tasksInteractor)
                .onAppear {
                    diContainer.appState.appDidFinishLaunching()
                }
                .onReceive(diContainer.appState.didBecomeActiveNotification) { _ in
                    diContainer.appState.appDidBecomeActive()
                }
        }
    }
}
