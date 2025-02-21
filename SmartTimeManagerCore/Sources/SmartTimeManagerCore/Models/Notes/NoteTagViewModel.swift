import SwiftUI

struct NoteTagViewModel: Identifiable {
    let id = UUID().uuidString
    let text: String
    let color: Color
    let tag: NoteModel.Tag
    
    init(tag: NoteModel.Tag) {
        self.tag = tag
        switch tag {
        case .text((let text, let color)):
            self.text = text
            self.color = color
        case .date((let date, let format)):
            self.text = date.string(template: format)
            self.color = .gray
        }
    }
}
