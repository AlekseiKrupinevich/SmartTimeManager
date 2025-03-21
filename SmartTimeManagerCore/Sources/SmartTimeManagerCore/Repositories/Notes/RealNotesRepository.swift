import Foundation

class RealNotesRepository: NotesRepository {
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
        CoreDataWrapper.subscribeOnUpdates(
            self,
            selector: #selector(handleRemoteChange)
        )
        fetchUpdatesIfNeeded()
    }
    
    deinit {
        CoreDataWrapper.unsubscribe(self)
    }
    
    @objc private func handleRemoteChange() {
        fetchUpdatesIfNeeded()
    }
    
    private func convert(_ dayReport: DayReport) -> NoteModel {
        NoteModel(
            id: dayReport.uuid ?? "",
            text: dayReport.text ?? "",
            tags: [.date(((dayReport.date ?? Date()).withoutTime, .dayTemplete))]
        )
    }
    
    private func convert(_ monthReport: MonthReport) -> NoteModel {
        NoteModel(
            id: monthReport.objectID.uriRepresentation().absoluteString,
            text: monthReport.text ?? "",
            tags: [.date(((monthReport.date ?? Date()).firstDayOfMonth, .monthTemplete))]
        )
    }
    
    private var isUpdateInProgress = false
    private var needToRepeatUpdate = false
    
    private func fetchUpdatesIfNeeded() {
        DispatchQueue.main.async {
            if self.isUpdateInProgress {
                self.needToRepeatUpdate = true
                return
            }
            self.isUpdateInProgress = true
            self.needToRepeatUpdate = false
            self.fetchUpdates()
        }
    }
    
    private func fetchUpdates() {
        _Concurrency.Task {
            let notes = await fetchNotes()
            let tags = getTags(notes: notes)
            
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
    
    private func fetchNotes() async -> [NoteModel] {
        let dayNotes = await CoreDataWrapper.dayReports()
        let monthNotes = await CoreDataWrapper.monthReports()
        let notes = await CoreDataWrapper.notes()
        return await MainActor.run {
            return (dayNotes.map { convert($0) } + monthNotes.map { convert($0) } + notes)
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
    }
    
    private func getTags(notes: [NoteModel]) -> [NoteModel.Tag] {
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
