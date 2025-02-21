extension String: @retroactive Error {
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
