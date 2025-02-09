import SwiftUI

struct NoteModel {
    let id: String
    var text: String
    var marks: [Mark]
    
    enum Mark {
        case text((text: String, color: Color))
        case date((date: Date, template: String))
    }
    
    init(
        id: String = UUID().uuidString,
        text: String = "",
        marks: [Mark] = []
    ) {
        self.id = id
        self.text = text
        self.marks = marks
    }
}
