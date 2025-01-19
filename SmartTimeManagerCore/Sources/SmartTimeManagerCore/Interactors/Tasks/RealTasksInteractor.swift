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
        return repository.tasks()
            .filter { $0.isOccurring(on: date) }
    }
    
    func task(id: String) -> TaskModel? {
        repository.task(id: id)
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
    
    func add(_ task: TaskModel) {
        var task = task
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.notes = task.notes.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    func deleteTask(id: String) {
        repository.deleteTask(id: id)
        objectWillChange.send()
    }
}
