import SwiftUI

struct NoteListItemViewModel: Identifiable {
    let id: String
    let text: String
    let marks: [Mark]
    
    struct Mark: Identifiable {
        let id = UUID().uuidString
        let text: String
        let color: Color
    }
}
