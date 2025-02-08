import SwiftUI

struct NoteModel {
    let id: String
    let text: String
    let marks: [Mark]
    
    enum Mark {
        case text((text: String, color: Color))
        case date((date: Date, template: String))
    }
}
