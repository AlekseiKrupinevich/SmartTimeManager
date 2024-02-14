import SwiftUI
import UIKit

extension Font {
    var lineHeight: Double {
        switch self {
        case .body:
            return UIFont.preferredFont(forTextStyle: .body).lineHeight
        default:
            return 0 
        }
    }
}
