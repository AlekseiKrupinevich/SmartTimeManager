import SwiftUI

class NotesViewModel<DI: DIProtocol>: ObservableObject {
    @Published var items: [NoteListItemViewModel] = []
    @Published var isApplyFiltersSheetVisible = false
    @Published var isAddNoteSheetVisible = false
    
    var interactor: DI.NotesInteractorType?
    
    func update() {
        guard let interactor else {
            return
        }
        objectWillChange.send()
        items = interactor.notes().map { note in
            return .init(
                id: note.id,
                text: note.text,
                marks: note.marks.map { mark in
                    switch mark {
                    case .text((let text, let color)):
                        return .init(text: text, color: color)
                    case .date((let date, let format)):
                        let text = date.string(template: format)
                        return .init(text: text, color: .gray)
                    }
                }
            )
        }
    }
    
    func deleteNote(id: String) {
        interactor?.deleteNote(id: id)
    }
    
    func deleteNotes(_ indexSet: IndexSet) {
        indexSet
            .compactMap { index -> String? in
                guard index < items.count else {
                    return nil
                }
                return items[index].id
            }
            .forEach { id in
                interactor?.deleteNote(id: id)
            }
    }
}
