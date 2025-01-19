import Foundation

extension TaskModel {
    init(
        id: String = UUID().uuidString,
        title: String = "",
        notes: String = "",
        date: Date = Date().withoutTime
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.type = .oneTime(.init(date: date))
        self.completionDates = []
    }
    
    func isOccurring(on date: Date) -> Bool {
        switch type {
        case .oneTime(let oneTime):
            if oneTime.date == date {
                return true
            } else if oneTime.carryOver {
                if !completionDates.isEmpty {
                    return completionDates.contains(date)
                } else {
                    return oneTime.date <= date && date.withoutTime <= Date().withoutTime
                }
            } else {
                return false
            }
        case .periodic(let periodic):
            switch periodic.timeFrame {
            case .off:
                break
            case .on(let timeFrame):
                guard
                    timeFrame.startDate <= date,
                    date <= timeFrame.endDate
                else {
                    return false
                }
            }
            switch periodic.type {
            case .everyday:
                return true
            case .lastDayOfMonth:
                return date.isLastDayOfMonth
            case .weekly(let days):
                return days.contains(date.components.weekday ?? 0)
            case .monthly(let days):
                return days.contains(date.components.day ?? 0)
            }
        }
    }
    
    enum ValidationResult {
        case valid
        case emptyTitle
        case noOccurrences
    }
    
    func validate() -> ValidationResult {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .emptyTitle
        }
        switch type {
        case .oneTime(_):
            return .valid
        case .periodic(let periodic):
            return periodic.hasOccurrences ? .valid : .noOccurrences
        }
    }
}

extension TaskModel: Equatable {
    static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.notes == rhs.notes &&
        lhs.type == rhs.type &&
        lhs.completionDates == rhs.completionDates
    }
}

extension TaskModel.TaskType: Equatable {
    static func == (lhs: TaskModel.TaskType, rhs: TaskModel.TaskType) -> Bool {
        switch lhs {
        case .oneTime(let lhs):
            guard case let .oneTime(rhs) = rhs else {
                return false
            }
            return lhs == rhs
        case .periodic(let lhs):
            guard case let .periodic(rhs) = rhs else {
                return false
            }
            return lhs.timeFrame == rhs.timeFrame && lhs.type == rhs.type
        }
    }
}

extension TaskModel.TaskType.OneTime: Equatable {
    static func == (
        lhs: TaskModel.TaskType.OneTime,
        rhs: TaskModel.TaskType.OneTime
    ) -> Bool {
        lhs.date == rhs.date
    }
}

extension TaskModel.TaskType.Periodic.TimeFrame: Equatable {
    static func == (
        lhs: TaskModel.TaskType.Periodic.TimeFrame,
        rhs: TaskModel.TaskType.Periodic.TimeFrame
    ) -> Bool {
        switch lhs {
        case .on(let lhs):
            guard case let .on(rhs) = rhs else {
                return false
            }
            return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
        case .off:
            guard case .off = rhs else {
                return false
            }
            return true
        }
    }
}

extension TaskModel.TaskType.Periodic.PeriodType: Equatable {
    static func == (
        lhs: TaskModel.TaskType.Periodic.PeriodType,
        rhs: TaskModel.TaskType.Periodic.PeriodType
    ) -> Bool {
        switch lhs {
        case .everyday:
            guard case .everyday = rhs else {
                return false
            }
            return true
        case .weekly(let lhs):
            guard case let .weekly(rhs) = rhs else {
                return false
            }
            return lhs == rhs
        case .monthly(let lhs):
            guard case let .monthly(rhs) = rhs else {
                return false
            }
            return lhs == rhs
        case .lastDayOfMonth:
            guard case .lastDayOfMonth = rhs else {
                return false
            }
            return true
        }
    }
}

extension TaskModel.TaskType.Periodic {
    var hasOccurrences: Bool {
        switch timeFrame {
        case .off:
            switch type {
            case .everyday:
                return true
            case .lastDayOfMonth:
                return true
            case .weekly(let days):
                return !days.isEmpty
            case .monthly(let days):
                return !days.isEmpty
            }
        case .on(let timeFrame):
            var date = timeFrame.startDate
            while date <= timeFrame.endDate {
                switch type {
                case .everyday:
                    return true
                case .lastDayOfMonth:
                    if date.isLastDayOfMonth {
                        return true
                    }
                case .weekly(let days):
                    if days.contains(date.components.weekday ?? 0) {
                        return true
                    }
                case .monthly(let days):
                    if days.contains(date.components.day ?? 0) {
                        return true
                    }
                }
                date = date.nextDay
            }
            return false
        }
    }
}
