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
            return lhsText == rhsText && lhsColor == rhsColor
        case let (.date((lhsDate, lhsTemplate)), .date((rhsDate, rhsTemplate))):
            return lhsDate == rhsDate && lhsTemplate == rhsTemplate
        default:
            return false
        }
    }
}
