import SwiftUI

class TasksViewModel<DI: DIProtocol>: ObservableObject {
    @Published var date = Date().withoutTime
    @Published var dateOfLastUpdate = Date().withoutTime
    @Published var items: [TaskListItemViewModel] = []
    @Published var isSelectDateSheetVisible = false
    @Published var isAddTaskSheetVisible = false
    
    var interactor: DI.TasksInteractorType?
    
    func update() {
        guard let interactor else {
            return
        }
        objectWillChange.send()
        items = interactor.tasks(on: date).map { task in
            let isCompleted = task.completionDates.contains(date)
            return .init(
                id: task.id,
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
        interactor?.deleteTask(id: id)
    }
    
    func deleteTasks(_ indexSet: IndexSet) {
        indexSet
            .forEach {
                guard $0 < items.count else {
                    return
                }
                let id = items[$0].id
                interactor?.deleteTask(id: id)
            }
    }
    
    func toggleTaskCompletion(id: String) {
        guard
            let interactor,
            var task = interactor.task(id: id)
        else {
            return
        }
        let isCompleted = task.completionDates.contains(date)
        if isCompleted {
            task.completionDates.remove(date)
        } else {
            task.completionDates.insert(date)
        }
        interactor.update(task)
    }
    
    func swithToNewDayIfNeeded() {
        let today = Date().withoutTime
        if dateOfLastUpdate != today {
            selectDate(date: today)
        }
    }
}
