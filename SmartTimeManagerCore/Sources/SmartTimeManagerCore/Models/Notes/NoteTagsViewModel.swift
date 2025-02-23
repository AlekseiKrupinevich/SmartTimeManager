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
    
    func applyDateTag(_ dateTag: DateTag) {
        if let tag = tag(dateTag: dateTag) {
            applyTag(tag)
        }
    }
    
    func isApplied(_ dateTag: DateTag) -> Bool {
        guard let tag = tag(dateTag: dateTag) else {
            return false
        }
        return note.tags.contains(tag)
    }
    
    func removeTag(id: String) {
        guard let tag = appliedTags.first(where: { $0.id == id }) else {
            return
        }
        note.tags.removeAll { $0 == tag.tag }
        update()
    }
    
    func validateNewTag(text: String) throws {
        if text.isEmpty {
            throw "Text is empty"
        }
        if (appliedTags + availableTags).contains(where: {
            $0.text.compare(text, options: .caseInsensitive) == .orderedSame
        }) {
            throw "A tag with this text already exists"
        }
    }
    
    func validateNewTag(date: Date, template: String) throws {
        if appliedTags.contains(where: {
            $0.tag == .date((date: date, template: template))
        }) {
            throw "The tag is already applied"
        }
    }
    
    private func tag(dateTag: DateTag) -> NoteModel.Tag? {
        switch dateTag.type {
        case .today:
            return .date((date: Date().withoutTime, template: .dayTemplete))
        case .currentMonth:
            return .date((date: Date().firstDayOfMonth, template: .monthTemplete))
        case .currentYear:
            return .date((date: Date().firstDayOfYear, template: .yearTemplete))
        case .customDate:
            return nil
        }
    }
}
