import SwiftUI

class AppState: ObservableObject {
    private let tasksInteractor: TasksInteractor
    
    init(tasksInteractor: TasksInteractor) {
        self.tasksInteractor = tasksInteractor
    }
    
    func appDidFinishLaunching() {
        tasksInteractor.updateTaskList()
        tasksInteractor.subscribeOnUpdates()
    }
    
    func appDidBecomeActive() {
        tasksInteractor.swithToNewDayIfNeeded()
    }
}
