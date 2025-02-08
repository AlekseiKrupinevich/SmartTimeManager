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
    
    func deleteNote(id: String) {
        repository.deleteNote(id: id)
        objectWillChange.send()
    }
}
