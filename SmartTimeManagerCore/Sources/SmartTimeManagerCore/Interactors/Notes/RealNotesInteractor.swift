import SwiftUI

class RealNotesInteractor: NotesInteractor {
    private let repository: any NotesRepository
    
    init(repository: any NotesRepository) {
        self.repository = repository
        repository.subscribe { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func notes() -> [NoteModel] {
        repository.notes()
    }
    
    func note(id: String) -> NoteModel? {
        return repository.note(id: id)
    }
    
    func tags() -> [NoteModel.Tag] {
        repository.tags()
    }
    
    func validate(_ note: NoteModel) throws {
        switch note.validate() {
        case .emptyText:
            throw "There is no text"
        case .valid:
            break
        }
    }
    
    func add(_ note: NoteModel) {
        var note = note
        note.text = note.text.trimmingCharacters(in: .whitespacesAndNewlines)
        repository.add(note: note)
        objectWillChange.send()
    }
    
    func update(_ note: NoteModel) {
        var note = note
        note.text = note.text.trimmingCharacters(in: .whitespacesAndNewlines)
        repository.update(note: note)
        objectWillChange.send()
    }
    
    func deleteNote(id: String) {
        repository.deleteNote(id: id)
        objectWillChange.send()
    }
}
