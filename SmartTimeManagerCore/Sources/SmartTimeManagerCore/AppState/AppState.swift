import SwiftUI

class AppState: ObservableObject {
    let didBecomeActiveNotification = NotificationCenter.default.publisher(for: UIScene.didActivateNotification)
    private var subscribersOnDidBecomeActive: [any DidBecomeActiveSubscriber] = []
    
    @Published var settings = Settings()
    
    func appDidFinishLaunching() { }
    
    func appDidBecomeActive() {
        CoreDataWrapper.update()
        subscribersOnDidBecomeActive.forEach { $0.appDidBecomeActive() }
    }
    
    func subscribeOnDidBecomeActive(_ subscriber: any DidBecomeActiveSubscriber) {
        subscribersOnDidBecomeActive.append(subscriber)
    }
    
    func unsubscribeOnDidBecomeActive(_ subscriber: any DidBecomeActiveSubscriber) {
        subscribersOnDidBecomeActive.removeAll { $0.id == subscriber.id }
    }
}
