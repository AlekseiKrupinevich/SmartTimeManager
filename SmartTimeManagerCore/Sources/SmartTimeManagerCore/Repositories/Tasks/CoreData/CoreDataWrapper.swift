import CoreData

struct CoreDataWrapper {
    private nonisolated(unsafe) static var container: NSPersistentCloudKitContainer = {
        guard let url = Bundle.module.url(forResource:"CoreDataModel", withExtension: "momd") else {
            fatalError("Couldn't find CoreDataModel")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Coundn't load managed object model")
        }
        let container = NSPersistentCloudKitContainer(
            name: "CoreDataModel",
            managedObjectModel: managedObjectModel
        )
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        let description = container.persistentStoreDescriptions.first
        
        description?.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )
        description?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                // TODO: Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
                /*
                 Typical reasons for an error here include:
                 – The parent directory does not exist, cannot be created, or disallows writing.
                 – The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 – The device is out of space.
                 – The store could not be migrated to the current model version.
                */
            }
        }
        
        return container
    }()
    
    private static var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    static func update() {
        viewContext.refreshAllObjects()
    }
    
    static func task(id: String) -> Task? {
        let request = NSFetchRequest<Task>(entityName: "Task")
        request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [id])
        let fetchResult = try? viewContext.fetch(request)
        return fetchResult?.first
    }
    
    static func tasks() -> [Task] {
        let request = NSFetchRequest<Task>(entityName: "Task")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createDate, ascending: true)]
        let fetchResult = try? viewContext.fetch(request)
        return fetchResult ?? []
    }
    
    static func subscribeOnUpdates(_ subscriber: Any, selector: Selector) {
        NotificationCenter.default.addObserver(
            subscriber,
            selector: selector,
            name: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }
    
    static func unsubscribe(_ subscriber: Any) {
        NotificationCenter.default.removeObserver(subscriber)
    }
    
    static func add(_ taskModel: TaskModel) {
        let task = Task(context: viewContext)
        task.uuid = taskModel.id
        task.createDate = Date()
        updateTask(task, taskModel: taskModel)
    }
    
    static func update(_ taskModel: TaskModel) {
        guard let task = task(id: taskModel.id) else {
            return
        }
        updateTask(task, taskModel: taskModel)
    }
    
    static func updateTask(_ task: Task, taskModel: TaskModel) {
        task.name = taskModel.title
        task.descr = taskModel.notes
        
        let completionConditions: TaskCompletionConditions = {
            if let completionConditions = task.completionConditions {
                return completionConditions
            } else {
                let completionConditions = TaskCompletionConditions(context: viewContext)
                task.completionConditions = completionConditions
                return completionConditions
            }
        }()
        
        switch taskModel.type {
        case .oneTime(let oneTime):
            completionConditions.type = 1
            completionConditions.oneTimeDate = oneTime.date
            completionConditions.oneTimeCarryOver = oneTime.carryOver
        case .periodic(let periodic):
            completionConditions.type = 2
            
            switch periodic.timeFrame {
            case .on(let on):
                completionConditions.periodFrom = on.startDate
                completionConditions.periodTo = on.endDate
            case .off:
                completionConditions.periodFrom = nil
                completionConditions.periodTo = nil
            }
            
            switch periodic.type {
            case .everyday:
                completionConditions.periodicType = 4
                completionConditions.points = ""
            case .weekly(let days):
                completionConditions.periodicType = 1
                completionConditions.points = Array(days)
                    .sorted()
                    .map { String($0) }
                    .joined(separator: ",")
            case .monthly(let days):
                completionConditions.periodicType = 2
                completionConditions.points = Array(days)
                    .sorted()
                    .map { String($0) }
                    .joined(separator: ",")
            case .lastDayOfMonth:
                completionConditions.periodicType = 3
                completionConditions.points = ""
            }
        }
        
        let states: Set<TaskState> = (task.states as? Set<TaskState>) ?? []
        
        task.states = NSSet(array: taskModel.completionDates.map { date in
            let state: TaskState
            if let _state = states.first(where: { $0.associatedDate == date }) {
                state = _state
            } else {
                state = TaskState(context: viewContext)
                state.associatedDate = date
            }
            state.complated = true
            return state
        })
        
        try? viewContext.save()
    }
    
    static func deleteTask(id: String) {
        guard let task = task(id: id) else {
            return
        }
        viewContext.delete(task)
        try? viewContext.save()
    }
}
