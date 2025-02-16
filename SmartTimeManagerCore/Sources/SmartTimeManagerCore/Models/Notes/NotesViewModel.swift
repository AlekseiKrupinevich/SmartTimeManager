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
                tags: note.tags
                    .sorted { lhs, rhs in
                        switch (lhs, rhs) {
                        case (.date(_), .text(_)):
                            return true
                        case (.text(_), .date(_)):
                            return false
                        case (.text(let lhs), .text(let rhs)):
                            return lhs.text.compare(rhs.text, options: .caseInsensitive) == .orderedAscending
                        case (.date(let lhs), .date(let rhs)):
                            switch lhs.template.compare(rhs.template) {
                            case .orderedAscending:
                                return true
                            case .orderedDescending:
                                return false
                            case .orderedSame:
                                return lhs.date < rhs.date
                            }
                        }
                    }
                    .map {
                        NoteTagViewModel(tag: $0)
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
