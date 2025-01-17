import Foundation

class RealTasksRepository: TasksRepository {
    private var subscriptions: [() -> Void] = []
    
    func tasks() -> [TaskModel] {
        return CoreDataWrapper.tasks()
            .compactMap { convert(task: $0) }
    }
    
    func task(id: String) -> TaskModel? {
        return CoreDataWrapper.task(id: id)
            .flatMap { convert(task: $0) }
    }
    
    func add(task: TaskModel) {
        CoreDataWrapper.add(task)
    }
    
    func update(task: TaskModel) {
        CoreDataWrapper.update(task)
    }
    
    func deleteTask(id: String) {
        CoreDataWrapper.deleteTask(id: id)
    }
    
    func subscribe(onUpdate: @escaping () -> Void) {
        subscriptions.append(onUpdate)
    }
    
    init() {
        CoreDataWrapper.subscribeOnUpdates(
            self,
            selector: #selector(handleRemoteChange)
        )
    }
    
    deinit {
        CoreDataWrapper.unsubscribe(self)
    }
    
    @objc private func handleRemoteChange() {
        for subscription in subscriptions {
            DispatchQueue.main.async {
                subscription()
            }
        }
    }
    
    private func convert(task: Task) -> TaskModel? {
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
}
