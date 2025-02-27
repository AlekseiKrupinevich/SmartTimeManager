import Foundation

class RealTasksRepository: TasksRepository {
    private var subscriptions: [() -> Void] = []
    private var _tasks: [TaskModel] = []
    
    func tasks() -> [TaskModel] {
        return _tasks
    }
    
    func task(id: String) -> TaskModel? {
        return _tasks.first { $0.id == id }
    }
    
    func add(task: TaskModel) {
        _tasks.append(task)
        _Concurrency.Task {
            await CoreDataWrapper.add(task)
        }
    }
    
    func update(task: TaskModel) {
        guard let index = _tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        _tasks[index] = task
        _Concurrency.Task {
            await CoreDataWrapper.update(task)
        }
    }
    
    func deleteTask(id: String) {
        _tasks.removeAll(where: { $0.id == id })
        _Concurrency.Task {
            await CoreDataWrapper.deleteTask(id: id)
        }
    }
    
    func subscribe(onUpdate: @escaping () -> Void) {
        subscriptions.append(onUpdate)
    }
    
    init() {
        CoreDataWrapper.subscribeOnUpdates(
            self,
            selector: #selector(handleRemoteChange)
        )
        fetchUpdatesIfNeeded()
    }
    
    deinit {
        CoreDataWrapper.unsubscribe(self)
    }
    
    @objc private func handleRemoteChange() {
        fetchUpdatesIfNeeded()
    }
    
    private func convert(_ task: Task) -> TaskModel? {
        guard let completionConditions = task.completionConditions else {
            return nil
        }
        
        let type: TaskModel.TaskType = {
            switch completionConditions.type {
            case 2:
                let timeFrame: TaskModel.TaskType.Periodic.TimeFrame = {
                    let from = completionConditions.periodFrom?.withoutTime
                    let to = completionConditions.periodTo?.withoutTime
                    if from != nil || to != nil {
                        return .on(
                            .init(
                                startDate: from ?? Date().withoutTime,
                                endDate: to ?? Date().withoutTime
                            )
                        )
                    } else {
                        return .off
                    }
                }()
                
                let type: TaskModel.TaskType.Periodic.PeriodType = {
                    switch completionConditions.periodicType {
                    case 1:
                        let days = (completionConditions.points ?? "")
                            .split(separator: ",")
                            .compactMap { Int($0) }
                        return .weekly(Set(days))
                    case 2:
                        let days = (completionConditions.points ?? "")
                            .split(separator: ",")
                            .compactMap { Int($0) }
                        return .monthly(Set(days))
                    case 3:
                        return .lastDayOfMonth
                    default:
                        return .everyday
                    }
                }()
                
                return .periodic(.init(timeFrame: timeFrame, type: type))
            default:
                let date = completionConditions.oneTimeDate?.withoutTime ?? Date().withoutTime
                let carryOver = completionConditions.oneTimeCarryOver ?? false
                return .oneTime(.init(date: date, carryOver: carryOver))
            }
        }()
        
        let completionDates: Set<Date> = {
            guard let states = task.states as? Set<TaskState> else {
                return []
            }
            let dates = states
                .filter { $0.complated }
                .compactMap { $0.associatedDate?.withoutTime }
            return Set(dates)
        }()
        
        return TaskModel(
            id: task.uuid ?? "",
            title: task.name ?? "",
            notes: task.descr ?? "",
            type: type,
            completionDates: completionDates
        )
    }
    
    private var isUpdateInProgress = false
    private var needToRepeatUpdate = false
    
    private func fetchUpdatesIfNeeded() {
        DispatchQueue.main.async {
            if self.isUpdateInProgress {
                self.needToRepeatUpdate = true
                return
            }
            self.isUpdateInProgress = true
            self.needToRepeatUpdate = false
            self.fetchUpdates()
        }
    }
    
    private func fetchUpdates() {
        _Concurrency.Task {
            let tasks = await fetchTasks()
            
            DispatchQueue.main.async {
                self._tasks = tasks
                
                for subscription in self.subscriptions {
                    subscription()
                }
                
                self.isUpdateInProgress = false
                
                if self.needToRepeatUpdate {
                    self.fetchUpdatesIfNeeded()
                }
            }
        }
    }
    
    private func fetchTasks() async -> [TaskModel] {
        let tasks = await CoreDataWrapper.tasks()
        return await MainActor.run {
            return tasks.compactMap { convert($0) }
        }
    }
}
