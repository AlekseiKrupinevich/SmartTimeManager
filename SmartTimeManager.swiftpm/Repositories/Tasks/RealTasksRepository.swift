import CoreDataWrapper

class RealTasksRepository: TasksRepository {
    func tasks() -> [TaskModel] {
        []
    }
    
    func task(id: String) -> TaskModel? {
        nil
    }
    
    func add(task: TaskModel) {
        
    }
    
    func update(task: TaskModel) {
        
    }
    
    func deleteTask(id: String) {
        
    }
    
    func subscribe(onUpdate: @escaping () -> Void) {
        
    }
    
    @MainActor private func testCoreDataWrapper() {
        let _ = CoreDataWrapper.viewContext
    }
}
