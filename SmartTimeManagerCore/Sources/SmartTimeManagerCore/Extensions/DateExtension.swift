import Foundation

extension Date {
    var components: DateComponents {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day, .weekday],
            from: self)
        components.calendar = Calendar.current
        components.timeZone = .gmt
        return components
    }
    
    var withoutTime: Date {
        components.date ?? Date()
    }
    
    var string: String {
        string(template: "EddMMMyyy")
    }
    
    var shortString: String {
        string(template: "EddMMM")
    }
    
    func string(template: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate(template)
        return dateFormatter.string(from: self)
    }
    
    var previousDay: Date {
        var components = self.components
        components.day = (components.day ?? 0) - 1
        return components.date ?? Date()
    }
    
    var nextDay: Date {
        var components = self.components
        components.day = (components.day ?? 0) + 1
        return components.date ?? Date()
    }
    
    var firstDayOfMonth: Date {
        var components = self.components
        components.day = 1
        return (components.date ?? Date()).withoutTime
    }
    
    var firstDayOfYear: Date {
        var components = self.components
        components.day = 1
        components.month = 1
        return (components.date ?? Date()).withoutTime
    }
    
    static var weekdays: [(day: Int, shortSymbol: String)] {
        guard
            let shortWeekdaySymbols = DateFormatter().shortWeekdaySymbols,
            !shortWeekdaySymbols.isEmpty
        else {
            return []
        }
        let weekdays = shortWeekdaySymbols.enumerated().map {
            return ($0.offset + 1, $0.element)
        }
        let firstWeekday = NSCalendar.current.firstWeekday
        guard firstWeekday > 1 else { 
            return weekdays
        }
        let index = firstWeekday - 1
        return Array(weekdays.suffix(from: index) + weekdays.prefix(upTo: index))
    }
    
    var isLastDayOfMonth: Bool {
        let components = DateComponents(
            calendar: Calendar.current,
            timeZone: .gmt,
            year: components.year,
            month: (components.month ?? 0) + 1,
            day: 0
        )
        let lastDayOfMonth = Calendar.current.date(from: components)
        return self == lastDayOfMonth
    }
    
    var month: Int {
        get {
            return components.month ?? 0
        }
        set {
            var components = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: self
            )
            components.calendar = Calendar.current
            components.timeZone = .gmt
            components.month = newValue
            if let date = Calendar.current.date(from: components) {
                self = date
            }
        }
    }
    
    var year: Int {
        get {
            return components.year ?? 0
        }
        set {
            var components = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: self
            )
            components.calendar = Calendar.current
            components.timeZone = .gmt
            components.year = newValue
            if let date = Calendar.current.date(from: components) {
                self = date
            }
        }
    }
}
