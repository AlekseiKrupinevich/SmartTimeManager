import Foundation

class MockTasksRepository: TasksRepository {
    private var _tasks: [TaskModel] = [
        .init(
            id: "1",
            title: "Task #1",
            notes: "",
            type: .oneTime(.init(date: Date().withoutTime)),
            completionDates: [Date().withoutTime]
        ),
        .init(
            id: "2",
            title: "The second task",
            notes: "",
            type: .oneTime(.init(date: Date().withoutTime.nextDay)),
            completionDates: []
        ),
        .init(
            id: "3",
            title: "This is an unusual task which has a lot of words and should be displayed in several lines",
            notes: "",
            type: .oneTime(.init(date: Date().withoutTime)),
            completionDates: []
        )
    ]
    
    func tasks() -> [TaskModel] {
        _tasks
    }
    
    func task(id: String) -> TaskModel? {
        _tasks.first { $0.id == id }
    }
    
    func add(task: TaskModel) {
        _tasks.append(task)
    }
    
    func update(task: TaskModel) {
        guard let index = _tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        _tasks[index] = task
    }
    
    func deleteTask(id: String) {
        _tasks.removeAll(where: { $0.id == id })
    }
}
