import Foundation

@MainActor
class RealNotesRepository: @MainActor NotesRepository {
    private var subscriptions: [() -> Void] = []
    private var _notes: [NoteModel] = []
    private var _tags: [NoteModel.Tag] = []
    
    func notes() -> [NoteModel] {
        return _notes
    }
    
    func note(id: String) -> NoteModel? {
        return _notes.first { $0.id == id }
    }
    
    func tags() -> [NoteModel.Tag] {
        return _tags
    }
    
    func add(note: NoteModel) {
        _notes.append(note)
        _Concurrency.Task {
            await CoreDataWrapper.add(note)
        }
    }
    
    func update(note: NoteModel) {
        guard let index = _notes.firstIndex(where: { $0.id == note.id }) else {
            return
        }
        _notes[index] = note
        _Concurrency.Task {
            await CoreDataWrapper.update(note)
        }
    }
    
    func deleteNote(id: String) {
        _notes.removeAll(where: { $0.id == id })
        _Concurrency.Task {
            await CoreDataWrapper.deleteNote(id: id)
        }
    }
    
    func subscribe(onUpdate: @escaping () -> Void) {
        subscriptions.append(onUpdate)
    }
    
    init() {
        CoreDataWrapper.subscribeOnUpdates { [weak self] _ in
            self?.fetchUpdatesIfNeeded()
        }
        fetchUpdatesIfNeeded()
    }
    
    deinit {
        DispatchQueue.main.async {
            CoreDataWrapper.unsubscribe(self)
        }
    }
    
    nonisolated private func convert(_ dayReport: DayReport) -> NoteModel {
        NoteModel(
            id: dayReport.uuid ?? "",
            text: dayReport.text ?? "",
            tags: [.date(((dayReport.date ?? Date()).withoutTime, .dayTemplete))]
        )
    }
    
    nonisolated private func convert(_ monthReport: MonthReport) -> NoteModel {
        NoteModel(
            id: monthReport.objectID.uriRepresentation().absoluteString,
            text: monthReport.text ?? "",
            tags: [.date(((monthReport.date ?? Date()).firstDayOfMonth, .monthTemplete))]
        )
    }
    
    private var isUpdateInProgress = false
    private var needToRepeatUpdate = false
    
    private func fetchUpdatesIfNeeded() {
        if self.isUpdateInProgress {
            self.needToRepeatUpdate = true
            return
        }
        self.isUpdateInProgress = true
        self.needToRepeatUpdate = false
        
        self.fetchUpdates()
    }
    
    private func fetchUpdates() {
        _Concurrency.Task {
            let dayNotes_ = await CoreDataWrapper.dayReports()
            let monthNotes_ = await CoreDataWrapper.monthReports()
            let notes_ = await CoreDataWrapper.notes()
            DispatchQueue.global(qos: .background).async {
                let notes = self.map(notes: (dayNotes_, monthNotes_, notes_))
                let tags = self.getTags(notes: notes)
                
                DispatchQueue.main.async {
                    self._notes = notes
                    self._tags = tags
                    
                    for subscription in self.subscriptions {
                        subscription()
                    }
                    
                    self.isUpdateInProgress = false
                    
                    if self.needToRepeatUpdate {
                        self.fetchUpdatesIfNeeded()
                    }
                }
            }
        }
    }
    
    nonisolated private func map(notes: ([DayReport], [MonthReport], [NoteModel])) -> [NoteModel] {
        return (notes.0.map { convert($0) } + notes.1.map { convert($0) } + notes.2)
            .sorted { lhs, rhs in
                if
                    let lhsTag = lhs.tags.first,
                    let rhsTag = rhs.tags.first,
                    lhsTag > rhsTag
                {
                    return true
                }
                return false
            }
    }
    
    nonisolated private func getTags(notes: [NoteModel]) -> [NoteModel.Tag] {
        notes
            .flatMap { $0.tags }
            .reduce(into: Set<NoteModel.Tag>()) { result, tag in
                if !result.contains(tag) {
                    result.insert(tag)
                }
            }
            .sorted()
    }
}
