import Foundation
import Combine

class TasksInteractor: ObservableObject {
    private let viewModel: TasksViewModel
    private let tasksRepository: TasksRepository
    
    init(
        viewModel: TasksViewModel,
        tasksRepository: TasksRepository
    ) {
        self.viewModel = viewModel
        self.tasksRepository = tasksRepository
    }
    
    func updateTaskList() {
        viewModel.items = tasksRepository.tasks()
            .filter { $0.isOccurring(on: viewModel.date) }
            .map { task in
                let isCompleted = task.completionDates.contains(viewModel.date)
                return .init(
                    id: task.id,
                    title: task.title,
                    isCompleted: isCompleted
                )
            }
        viewModel.updateItemsDate = Date().withoutTime
    }
    
    func showPreviousDay() {
        viewModel.date = viewModel.date.previousDay
        updateTaskList()
    }
    
    func showNextDay() {
        viewModel.date = viewModel.date.nextDay
        updateTaskList()
    }
    
    func showSelectDateSheet() {
        viewModel.isSelectDateSheetVisible = true
    }
    
    func showAddTaskSheet() {
        viewModel.isAddTaskSheetVisible = true
    }
    
    func hideSelectDateSheet() {
        viewModel.isSelectDateSheetVisible = false
    }
    
    func hideAddTaskSheet() {
        viewModel.isAddTaskSheetVisible = false
    }
    
    func selectDate(date: Date) {
        viewModel.date = date.withoutTime
        viewModel.isSelectDateSheetVisible = false
        updateTaskList()
    }
    
    func deleteTask(id: String) {
        viewModel.items.removeAll(where: { $0.id == id })
        tasksRepository.deleteTask(id: id)
    }
    
    func deleteTasks(_ indexSet: IndexSet) {
        indexSet
            .map { viewModel.items[$0].id }
            .forEach { tasksRepository.deleteTask(id: $0) }
        viewModel.items.remove(atOffsets: indexSet)
    }
    
    func toggleTaskCompletion(id: String) {
        guard
            var task = tasksRepository.task(id: id),
            let itemIndex = viewModel.items.firstIndex(where: { $0.id == id })
        else {
            return
        }
        viewModel.items[itemIndex].isCompleted.toggle()
        if viewModel.items[itemIndex].isCompleted {
            task.completionDates.insert(viewModel.date)
        } else {
            task.completionDates.remove(viewModel.date)
        }
        tasksRepository.update(task: task)
    }
    
    func addTask(_ task: TaskModel) {
        var task = task
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.notes = task.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        tasksRepository.add(task: task)
        updateTaskList()
        viewModel.isAddTaskSheetVisible = false
    }
    
    func task(id: String) -> TaskModel? {
        tasksRepository.task(id: id)
    }
    
    func update(_ task: TaskModel) {
        var task = task
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.notes = task.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        tasksRepository.update(task: task)
        updateTaskList()
    }
    
    func swithToNewDayIfNeeded() {
        let today = Date().withoutTime
        guard viewModel.updateItemsDate != today else {
            return
        }
        selectDate(date: today)
    }
    
    func validate(_ task: TaskModel) throws {
        switch task.validate() {
        case .emptyTitle:
            throw "The title is empty"
        case .noOccurrences:
            throw "There are no occurrences"
        case .valid:
            break
        }
    }
}
