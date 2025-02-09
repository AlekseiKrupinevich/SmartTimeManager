import SwiftUI

struct EditNoteView: View {
    @Binding var note: NoteModel
    let needFocusOnText: Bool
    @FocusState private var focused
    
    var body: some View {
        List {
            text
                .focused($focused)
        }
        .listStyle(PlainListStyle())
        .onAppear {
            if needFocusOnText {
                focused = true
            }
        }
    }
    
    private var text: some View {
        CustomTextEditor(text: $note.text, placeholder: "Text")
    }
}
