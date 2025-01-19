import SwiftUI

class AppState: ObservableObject {
    let didBecomeActiveNotification = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    
    func appDidFinishLaunching() { }
    
    func appDidBecomeActive() {
        CoreDataWrapper.update()
    }
}
