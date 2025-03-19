import SwiftUI

protocol LogsInteractor: ObservableObject {
    func logAppStarted()
    func logAppDidBecomeActive()
    func logTaskEvent(_ taskEvent: TaskEvent)
    func logNoteEvent(_ noteEvent: NoteEvent)
}

enum TaskEvent: String {
    case add
    case edit
    case delete
    case complete
    case uncomplete
}

enum NoteEvent: String {
    case add
    case edit
    case delete
    case applyFilters = "apply_filters"
}
