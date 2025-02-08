import SwiftUI

protocol NotesInteractor: ObservableObject {
    func notes() -> [NoteModel]
    func deleteNote(id: String)
}
