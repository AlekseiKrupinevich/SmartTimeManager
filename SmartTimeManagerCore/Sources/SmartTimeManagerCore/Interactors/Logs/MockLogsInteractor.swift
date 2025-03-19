import SwiftUI

class MockLogsInteractor: LogsInteractor {
    func logAppStarted() {
        print("Log: App started")
    }
    
    func logAppDidBecomeActive() {
        print("Log: App did become active")
    }
    
    func logTaskEvent(_ taskEvent: TaskEvent) {
        print("Log: Task event occurred <\(taskEvent.rawValue)>")
    }
    
    func logNoteEvent(_ noteEvent: NoteEvent) {
        print("Log: Note event occurred <\(noteEvent.rawValue)>")
    }
}
