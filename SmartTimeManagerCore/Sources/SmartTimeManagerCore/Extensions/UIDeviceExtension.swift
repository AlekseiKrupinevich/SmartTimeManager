import SwiftUI

extension UIDevice {
    static var isMac: Bool {
#if targetEnvironment(macCatalyst)
        return true
#else
        return false
#endif
    }
}
