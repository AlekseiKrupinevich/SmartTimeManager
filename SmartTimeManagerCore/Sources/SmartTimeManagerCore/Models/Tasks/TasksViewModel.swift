import SwiftUI

class TasksViewModel<DI: DIProtocol>: ObservableObject, DidBecomeActiveSubscriber {
    @Published var date = Date().withoutTime
    @Published var dateOfLastUpdate = Date().withoutTime
    @Published var items: [TaskListItemViewModel] = []
    @Published var isSelectDateSheetVisible = false
    @Published var isAddTaskSheetVisible = false
    
    let id = UUID().uuidString
    
    var tasksInteractor: DI.TasksInteractorType?
    var logsInteractor: DI.LogsInteractorType?
    
    var appState: AppState? {
        didSet {
            appState?.subscribeOnDidBecomeActive(self)
        }
    }
    
    deinit {
        appState?.unsubscribeOnDidBecomeActive(self)
    }
    
    func appDidBecomeActive() {
        swithToNewDayIfNeeded()
    }
    
    func update() {
        guard let tasksInteractor else {
            return
        }
        objectWillChange.send()
        items = tasksInteractor.tasks(on: date).enumerated().map { index, task in
            let isCompleted = task.completionDates.contains(date)
            return .init(
                id: task.id,
                index: index + 1,
                title: task.title,
                isCompleted: isCompleted
            )
        }
        dateOfLastUpdate = Date().withoutTime
    }
    
    func selectDate(date: Date) {
        self.date = date.withoutTime
        update()
        isSelectDateSheetVisible = false
    }
    
    func showPreviousDay() {
        date = date.previousDay
        update()
    }
    
    func showNextDay() {
        date = date.nextDay
        update()
    }
    
    func deleteTask(id: String) {
        tasksInteractor?.deleteTask(id: id)
        logsInteractor?.logTaskEvent(.delete)
    }
    
    func deleteTasks(_ indexSet: IndexSet) {
        indexSet
            .compactMap { index -> String? in
                guard index < items.count else {
                    return nil
                }
                return items[index].id
            }
            .forEach { id in
                tasksInteractor?.deleteTask(id: id)
                logsInteractor?.logTaskEvent(.delete)
            }
    }
    
    func toggleTaskCompletion(id: String) {
        guard
            let tasksInteractor,
            var task = tasksInteractor.task(id: id)
        else {
            return
        }
        let isCompleted = task.completionDates.contains(date)
        if isCompleted {
            task.completionDates.remove(date)
            logsInteractor?.logTaskEvent(.uncomplete)
        } else {
            task.completionDates.insert(date)
            logsInteractor?.logTaskEvent(.complete)
        }
        tasksInteractor.update(task)
    }
    
    func swithToNewDayIfNeeded() {
        let today = Date().withoutTime
        if dateOfLastUpdate != today {
            selectDate(date: today)
        }
    }
    
    func move(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to)
        var tasks = items.compactMap { tasksInteractor?.task(id: $0.id) }
        for i in tasks.indices {
            tasks[i].priority = i
        }
        tasksInteractor?.update(tasks)
    }
}
