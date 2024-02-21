protocol TasksRepository {
    func tasks() -> [TaskModel]
    func task(id: String) -> TaskModel?
    func add(task: TaskModel)
    func update(task: TaskModel)
    func deleteTask(id: String)
    func subscribe(onUpdate: @escaping () -> Void)
}
