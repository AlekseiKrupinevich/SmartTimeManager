import SwiftUI

class NotesViewModel<DI: DIProtocol>: ObservableObject {
    @Published var items: [NoteListItemViewModel] = []
    @Published var isApplyFiltersSheetVisible = false
    @Published var isAddNoteSheetVisible = false
    @Published var filters = Filters()
    
    var notesInteractor: DI.NotesInteractorType?
    var logsInteractor: DI.LogsInteractorType?
    
    func update() {
        guard let notesInteractor else {
            return
        }
        objectWillChange.send()
        items = notesInteractor.notes()
            .filter { note in
                switch filters.appliedFilter {
                case nil:
                    return true
                case .byTag(let text):
                    return note.tags.contains(where: { tag in
                        switch tag {
                        case .text((let tagText, _)):
                            return tagText == text
                        case .date(_):
                            return false
                        }
                    })
                case .byDate(let dateFilter):
                    return note.tags.contains(where: { tag in
                        switch tag {
                        case .text(_):
                            return false
                        case .date((let date, let template)):
                            guard template == dateFilter.template else {
                                return false
                            }
                            if let from = dateFilter.from, date < from {
                                return false
                            }
                            if let to = dateFilter.to, date > to {
                                return false
                            }
                            return true
                        }
                    })
                case .withoutTags:
                    return note.tags.isEmpty
                }
            }
            .map { note in
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
                                let lhsPriority = lhs.template.templatePriority
                                let rhsPriority = rhs.template.templatePriority
                                if lhsPriority < rhsPriority {
                                    return true
                                }
                                if lhsPriority > rhsPriority {
                                    return false
                                }
                                return lhs.date < rhs.date
                            }
                        }
                        .map {
                            NoteTagViewModel(tag: $0)
                        }
                )
            }
    }
    
    func deleteNote(id: String) {
        notesInteractor?.deleteNote(id: id)
        logsInteractor?.logNoteEvent(.delete)
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
                notesInteractor?.deleteNote(id: id)
                logsInteractor?.logNoteEvent(.delete)
            }
    }
}
