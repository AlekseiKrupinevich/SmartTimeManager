import SwiftUI

class AppState: ObservableObject {

#if canImport(UIKit)
    let didBecomeActiveNotification = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
#else
    let didBecomeActiveNotification = NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
#endif
    
    func appDidFinishLaunching() { }
    
    func appDidBecomeActive() { }
}
