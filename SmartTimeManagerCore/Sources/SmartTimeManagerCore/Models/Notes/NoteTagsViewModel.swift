import SwiftUI

class NoteTagsViewModel<DI: DIProtocol>: ObservableObject {
    @Published var appliedTags: [NoteTagViewModel] = []
    @Published var availableTags: [NoteTagViewModel] = []
    var interactor: DI.NotesInteractorType?
    @Binding private var note: NoteModel
    
    init(note: Binding<NoteModel>) {
        _note = note
    }
    
    let availableDateTags = [
        "Today",
        "Current month",
        "Current year",
        "Custom date"
    ]
    
    func update() {
        guard let interactor else {
            return
        }
        appliedTags = note.tags
            .map {
                NoteTagViewModel(tag: $0)
            }
            .sorted(by: sort)
        availableTags = interactor.tags()
            .map {
                NoteTagViewModel(tag: $0)
            }
            .filter { tag in
                !appliedTags.contains(where: { $0.text == tag.text })
            }
            .sorted(by: sort)
    }
    
    func applyTag(_ tag: NoteTagViewModel) {
        note.tags.append(.text((tag.text, tag.color)))
        update()
    }
    
    func removeTag(id: String) {
        guard let removedTag = appliedTags.first(where: { $0.id == id }) else {
            return
        }
        note.tags.removeAll(where: { tag in
            switch tag {
            case .text((let text, _)):
                return text == removedTag.text
            case .date(_):
                return false
            }
        })
        update()
    }
    
    func validateNewTag(text: String) -> Bool {
        !(appliedTags + availableTags).contains {
            $0.text.compare(text, options: .caseInsensitive) == .orderedSame
        }
    }
    
    private func sort(lhs: NoteTagViewModel, rhs: NoteTagViewModel) -> Bool {
        return lhs.text.compare(rhs.text, options: .caseInsensitive) == .orderedAscending
    }
}
