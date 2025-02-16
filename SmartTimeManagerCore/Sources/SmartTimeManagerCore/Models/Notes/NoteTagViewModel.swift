import SwiftUI

struct NoteTagViewModel: Identifiable {
    let id: String
    let text: String
    let color: Color
    
    init(
        id: String = UUID().uuidString,
        text: String,
        color: Color
    ) {
        self.id = id
        self.text = text
        self.color = color
    }
    
    init(tag: NoteModel.Tag) {
        switch tag {
        case .text((let text, let color)):
            self.init(text: text, color: color)
        case .date((let date, let format)):
            let text = date.string(template: format)
            self.init(text: text, color: .gray)
        }
    }
}
