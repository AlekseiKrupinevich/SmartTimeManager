import Foundation
import CoreDataWrapper

class RealTasksRepository: TasksRepository {
    func tasks() -> [TaskModel] {
        return CoreDataWrapper.tasks().map { convert(task: $0) }
    }
    
    func task(id: String) -> TaskModel? {
        return CoreDataWrapper.task(id: id).map { convert(task: $0) }
    }
    
    func add(task: TaskModel) {
        // TODO: priority 3
    }
    
    func update(task: TaskModel) {
        // TODO: priority 3
    }
    
    func deleteTask(id: String) {
        // TODO: priority 3
    }
    
    func subscribe(onUpdate: @escaping () -> Void) {
        // TODO: priority 2
    }
    
    private func convert(task: Task) -> TaskModel {
        let type: TaskModel.TaskType = {
            guard let completionConditions = task.completionConditions else {
                return .oneTime(.init(date: Date().withoutTime))
            }
            switch completionConditions.type {
            case 2:
                let timeFrame: TaskModel.TaskType.Periodic.TimeFrame = {
                    let from = task.completionConditions?.periodFrom?.withoutTime
                    let to = task.completionConditions?.periodTo?.withoutTime
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
                        let days = (completionConditions.points ?? "").split(separator: ",").compactMap { Int($0) }
                        return .weekly(Set(days))
                    case 2:
                        let days = (completionConditions.points ?? "").split(separator: ",").compactMap { Int($0) }
                        return .monthly(Set(days))
                    case 3:
                        return .lastDayOfMonth
                    default:
                        return .everyday
                    }
                }()
                
                return .periodic(.init(timeFrame: timeFrame, type: type))
            default:
                // TODO: Decide what to do with CarryOver
                // taskModel.oneTimeCarryOver = task?.completionConditions?.oneTimeCarryOver ?? false
                let date = task.completionConditions?.oneTimeDate ?? Date().withoutTime
                return .oneTime(.init(date: date))
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
