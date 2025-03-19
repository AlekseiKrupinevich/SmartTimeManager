import SwiftUI

struct SmartTimeManagerView<DI: DIProtocol>: View {
    @StateObject private var diContainer: DIContainer<DI> = DIBuilder<DI>.build()
    
    var body: some View {
        ContentView<DI>()
            .environmentObject(diContainer.appState)
            .environmentObject(diContainer.tasksInteractor)
            .environmentObject(diContainer.notesInteractor)
            .environmentObject(diContainer.logsInteractor)
            .onAppear {
                diContainer.appState.appDidFinishLaunching()
                diContainer.logsInteractor.logAppStarted()
            }
            .onReceive(diContainer.appState.didBecomeActiveNotification) { _ in
                diContainer.appState.appDidBecomeActive()
                diContainer.logsInteractor.logAppDidBecomeActive()
            }
    }
}

#Preview {
    SmartTimeManagerView<MockDI>()
}
