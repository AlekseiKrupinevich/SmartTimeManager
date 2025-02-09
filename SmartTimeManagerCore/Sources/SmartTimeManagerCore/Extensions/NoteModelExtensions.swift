import Foundation

extension NoteModel {
    init() {
        id = UUID().uuidString
        text = ""
        marks = []
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
        lhs.marks == rhs.marks
    }
}

extension NoteModel.Mark: Equatable {
    static func == (lhs: NoteModel.Mark, rhs: NoteModel.Mark) -> Bool {
        switch (lhs, rhs) {
        case let (.text((lhsText, lhsColor)), .text((rhsText, rhsColor))):
            return lhsText == rhsText && lhsColor == rhsColor
        case let (.date((lhsDate, lhsTemplate)), .date((rhsDate, rhsTemplate))):
            return lhsDate == rhsDate && lhsTemplate == rhsTemplate
        default:
            return false
        }
    }
}
