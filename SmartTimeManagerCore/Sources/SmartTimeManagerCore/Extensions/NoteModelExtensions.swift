import Foundation

extension NoteModel {
    init() {
        id = UUID().uuidString
        text = ""
        tags = []
    }
    
    enum ValidationResult {
        case valid
        case emptyText
    }
    
    func validate() -> ValidationResult {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .emptyText
        }
        return .valid
    }
}

extension NoteModel: Equatable {
    static func == (lhs: NoteModel, rhs: NoteModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.tags == rhs.tags
    }
}

extension NoteModel.Tag: Equatable {
    static func == (lhs: NoteModel.Tag, rhs: NoteModel.Tag) -> Bool {
        switch (lhs, rhs) {
        case let (.text((lhsText, lhsColor)), .text((rhsText, rhsColor))):
            return lhsText.compare(rhsText, options: .caseInsensitive) == .orderedSame
        case let (.date((lhsDate, lhsTemplate)), .date((rhsDate, rhsTemplate))):
            return lhsDate.string(template: lhsTemplate) == rhsDate.string(template: rhsTemplate)
        default:
            return false
        }
    }
}

extension NoteModel.Tag: Comparable {
    static func < (lhs: NoteModel.Tag, rhs: NoteModel.Tag) -> Bool {
        switch (lhs, rhs) {
        case let (.text((lhsText, lhsColor)), .text((rhsText, rhsColor))):
            return lhsText.compare(rhsText, options: .caseInsensitive) == .orderedAscending
        case let (.date((lhsDate, lhsTemplate)), .date((rhsDate, rhsTemplate))):
            if lhsTemplate.templatePriority < rhsTemplate.templatePriority {
                return true
            }
            if lhsTemplate.templatePriority > rhsTemplate.templatePriority {
                return false
            }
            return lhsDate < rhsDate
        case (.date(_), .text(_)):
            return true
        case (.text(_), .date(_)):
            return false
        }
    }
}

extension NoteModel.Tag: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .text((let text, _)):
            hasher.combine(text)
        case .date((let date, let template)):
            hasher.combine(date)
            hasher.combine(template)
        }
    }
}
