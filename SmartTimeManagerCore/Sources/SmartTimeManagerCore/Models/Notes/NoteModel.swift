import SwiftUI

struct NoteModel {
    let id: String
    var text: String
    var tags: [Tag]
    
    enum Tag {
        case text((text: String, color: Color))
        case date((date: Date, template: String))
    }
    
    init(
        id: String = UUID().uuidString,
        text: String = "",
        tags: [Tag] = []
    ) {
        self.id = id
        self.text = text
        self.tags = tags
    }
}
