import SwiftUI

class RealTasksInteractor: TasksInteractor {
    private let repository: any TasksRepository
    
    init(repository: any TasksRepository) {
        self.repository = repository
        repository.subscribe { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func tasks(on date: Date) -> [TaskModel] {
        repository.tasks()
            .filter { $0.isOccurring(on: date) }
            .sorted { lhs, rhs in
                let lhsPriority = lhs.priority ?? 0
                let rhsPriority = rhs.priority ?? 0
                if lhsPriority != rhsPriority {
                    return lhsPriority < rhsPriority
                }
                return false
            }
    }
    
    func task(id: String) -> TaskModel? {
        repository.task(id: id)
    }
    
    func validate(_ task: TaskModel) throws {
        switch task.validate() {
        case .emptyTitle:
            throw "The title is empty".localized
        case .noOccurrences:
            throw "There are no occurrences".localized
        case .valid:
            break
        }
    }
    
    func add(_ task: TaskModel) {
        var task = task
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.notes = task.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if task.priority == nil {
            task.priority = repository.tasks()
                .compactMap(\.priority)
                .max()
                .map { $0 + 1 } ?? 0
        }
        repository.add(task: task)
        objectWillChange.send()
    }
    
    func update(_ task: TaskModel) {
        var task = task
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.notes = task.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        repository.update(task: task)
        objectWillChange.send()
    }
    
    func update(_ tasks: [TaskModel]) {
        tasks.forEach { update($0) }
    }
    
    func deleteTask(id: String) {
        repository.deleteTask(id: id)
        objectWillChange.send()
    }
}
