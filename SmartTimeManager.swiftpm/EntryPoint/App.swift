import SwiftUI

@main
struct SmartTimeManager: App {
    @StateObject private var appState: AppState
    @StateObject private var tasksViewModel: TasksViewModel
    @StateObject private var tasksInteractor: TasksInteractor
    
    private let didBecomeActiveNotification = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    
    init() {
        let instances = DI.build()
        _appState = StateObject(wrappedValue: instances.appState) 
        _tasksViewModel = StateObject(wrappedValue: instances.tasksViewModel)
        _tasksInteractor = StateObject(wrappedValue: instances.tasksInteractor)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(tasksViewModel)
                .environmentObject(tasksInteractor)
                .onAppear {
                    appState.appDidFinishLaunching()
                }
                .onReceive(didBecomeActiveNotification) { _ in
                    appState.appDidBecomeActive()
                }
        }
    }
}
