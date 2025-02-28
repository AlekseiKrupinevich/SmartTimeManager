import SwiftUI

extension String: @retroactive Error { }

extension String {
    static let dayTemplete: String = "ddMMMyyy"
    static let monthTemplete: String = "MMMyyy"
    static let yearTemplete: String = "yyy"
    
    var templatePriority: Int {
        if self == .dayTemplete { return 1 }
        if self == .monthTemplete { return 2 }
        if self == .yearTemplete { return 3 }
        return 4
    }
}

extension String {
    init(_ color: Color) {
        let components = color.resolve(in: .init())
        
        let r = String(Int(components.red * 255), radix: 16, uppercase: true)
        let g = String(Int(components.green * 255), radix: 16, uppercase: true)
        let b = String(Int(components.blue * 255), radix: 16, uppercase: true)
        let a = String(Int(components.opacity * 255), radix: 16, uppercase: true)
        
        let red = (r.count == 2) ? r : ("0" + r)
        let green = (g.count == 2) ? g : ("0" + g)
        let blue = (b.count == 2) ? b : ("0" + b)
        let alpha = (a.count == 2) ? a : ("0" + a)
        
        self.init(red + green + blue + alpha)
    }
}
