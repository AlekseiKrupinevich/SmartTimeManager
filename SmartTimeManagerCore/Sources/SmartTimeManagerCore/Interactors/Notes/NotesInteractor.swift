import SwiftUI

protocol NotesInteractor: ObservableObject {
    func notes() -> [NoteModel]
    func note(id: String) -> NoteModel?
    func tags() -> [NoteModel.Tag]
    func validate(_ note: NoteModel) throws
    func add(_ note: NoteModel)
    func update(_ note: NoteModel)
    func deleteNote(id: String)
}
