import SwiftUI

class AppState: ObservableObject {
    private let tasksInteractor: TasksInteractor
    
    init(tasksInteractor: TasksInteractor) {
        self.tasksInteractor = tasksInteractor
    }
    
    func appDidFinishLaunching() {
        tasksInteractor.updateTaskList()
    }
    
    func appDidBecomeActive() {
        tasksInteractor.swithToNewDayIfNeeded()
    }
}
