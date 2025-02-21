import SwiftUI

class NoteTagsViewModel<DI: DIProtocol>: ObservableObject {
    @Binding private var note: NoteModel
    var interactor: DI.NotesInteractorType?
    @Published var appliedTags: [NoteTagViewModel] = []
    @Published var availableTags: [NoteTagViewModel] = []
    
    init(note: Binding<NoteModel>) {
        _note = note
    }
    
    let availableDateTags: [DateTag] = [
        .init(title: "Today", type: .today),
        .init(title: "Current month", type: .currentMonth),
        .init(title: "Current year", type: .currentYear),
        .init(title: "Custom date", type: .customDate)
    ]
    
    struct DateTag: Identifiable {
        let id = UUID().uuidString
        let title: String
        let type: TagType
        enum TagType {
            case today
            case currentMonth
            case currentYear
            case customDate
        }
    }
    
    func update() {
        guard let interactor else {
            return
        }
        appliedTags = note.tags
            .map {
                NoteTagViewModel(tag: $0)
            }
        availableTags = interactor.tags()
            .filter { tag in
                switch tag {
                case .text(_):
                    return !appliedTags.contains(where: { $0.tag == tag })
                case .date((let date, let template)):
                    return false
                }
            }
            .map {
                NoteTagViewModel(tag: $0)
            }
    }
    
    func applyTag(_ tag: NoteModel.Tag) {
        note.tags.append(tag)
        note.tags.sort()
        update()
    }
    
    func applyDateTag(_ tag: DateTag) {
        switch tag.type {
        case .today:
            applyTag(.date((date: Date().withoutTime, template: .dayTemplete)))
        case .currentMonth:
            applyTag(.date((date: Date().firstDayOfMonth, template: .monthTemplete)))
        case .currentYear:
            applyTag(.date((date: Date().firstDayOfYear, template: .yearTemplete)))
        case .customDate:
            break
        }
    }
    
    func removeTag(id: String) {
        guard let tag = appliedTags.first(where: { $0.id == id }) else {
            return
        }
        note.tags.removeAll { $0 == tag.tag }
        update()
    }
    
    func validateNewTag(text: String) -> Bool {
        !(appliedTags + availableTags).contains {
            $0.text.compare(text, options: .caseInsensitive) == .orderedSame
        }
    }
}
