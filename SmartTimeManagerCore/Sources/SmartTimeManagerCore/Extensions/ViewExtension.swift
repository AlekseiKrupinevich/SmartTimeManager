import SwiftUI

extension View {
    var isMac: Bool {
#if targetEnvironment(macCatalyst)
        return true
#else
        return false
#endif
    }
}
