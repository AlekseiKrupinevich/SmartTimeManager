import SwiftUI

protocol TasksInteractor: ObservableObject {
    func tasks(on date: Date) -> [TaskModel]
    func task(id: String) -> TaskModel?
    func validate(_ task: TaskModel) throws
    func add(_ task: TaskModel)
    func update(_ task: TaskModel)
    func deleteTask(id: String)
}
