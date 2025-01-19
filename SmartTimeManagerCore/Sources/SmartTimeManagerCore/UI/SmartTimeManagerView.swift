import SwiftUI

public struct SmartTimeManagerView: View {
    private typealias DI = RealDI
    
    @StateObject private var diContainer: DIContainer<DI> = DIBuilder.build()
    
    public init() {}
    
    public var body: some View {
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
