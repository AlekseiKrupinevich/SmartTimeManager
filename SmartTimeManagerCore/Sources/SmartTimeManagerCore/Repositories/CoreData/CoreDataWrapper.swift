import CoreData
import SwiftUI

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
    
    static func updateCoreDataSchema() {
        do {
            try container.initializeCloudKitSchema(options: NSPersistentCloudKitContainerSchemaInitializationOptions())
        } catch {
            fatalError("initializeCloudKitSchema error: \(error)")
        }
    }
    
    static func task(id: String) async -> Task? {
        await MainActor.run {
            let request = NSFetchRequest<Task>(entityName: "Task")
            request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [id])
            let fetchResult = try? viewContext.fetch(request)
            return fetchResult?.first
        }
    }
    
    static func tasks() async -> [Task] {
        await MainActor.run {
            let request = NSFetchRequest<Task>(entityName: "Task")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createDate, ascending: true)]
            let fetchResult = try? viewContext.fetch(request)
            return fetchResult ?? []
        }
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
    
    static func add(_ taskModel: TaskModel) async {
        var task: Task? = nil
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                task = Task(context: viewContext)
                task?.uuid = taskModel.id
                task?.createDate = Date()
                continuation.resume()
            }
        }
        if let task {
            await updateTask(task, taskModel: taskModel)
        }
    }
    
    static func update(_ taskModel: TaskModel) async {
        guard let task = await task(id: taskModel.id) else {
            return
        }
        await updateTask(task, taskModel: taskModel)
    }
    
    static func updateTask(_ task: Task, taskModel: TaskModel) async {
        await MainActor.run {
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
    }
    
    static func deleteTask(id: String) async {
        guard let task = await task(id: id) else {
            return
        }
        await MainActor.run {
            viewContext.delete(task)
            try? viewContext.save()
        }
    }
    
    static func dayReports() async -> [DayReport] {
        await MainActor.run {
            let request = NSFetchRequest<DayReport>(entityName: "DayReport")
            let fetchResult = try? viewContext.fetch(request)
            return fetchResult ?? []
        }
    }
    
    static func monthReports() async -> [MonthReport] {
        await MainActor.run {
            let request = NSFetchRequest<MonthReport>(entityName: "MonthReport")
            let fetchResult = try? viewContext.fetch(request)
            return fetchResult ?? []
        }
    }
    
    static func notes() async -> [NoteModel] {
        await MainActor.run {
            let request = NSFetchRequest<Note>(entityName: "Note")
            let fetchResult = try? viewContext.fetch(request)
            return (fetchResult ?? []).map { convert($0) }
        }
    }
    
    static func add(_ noteModel: NoteModel) async {
        var note: Note? = nil
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                note = Note(context: viewContext)
                note?.uuid = noteModel.id
                continuation.resume()
            }
        }
        if let note {
            await updateNote(note, noteModel: noteModel)
        }
    }
    
    static func updateNote(_ note: Note, noteModel: NoteModel) async {
        await MainActor.run {
            note.lastModifiedDate = Date()
            note.text = noteModel.text
            let tags: Set<NoteTag> = (note.tags as? Set<NoteTag>) ?? []
            
            note.tags = NSSet(array: noteModel.tags.map { tag in
                let noteTag: NoteTag
                if let _noteTag = tags.first(where: {
                    convert($0) == tag
                }) {
                    noteTag = _noteTag
                } else {
                    noteTag = convert(tag)
                }
                return noteTag
            })
            
            try? viewContext.save()
        }
    }
    
    private static func convert(_ noteTag: NoteTag) -> NoteModel.Tag? {
        switch noteTag.type {
        case 1:
            guard
                let text = noteTag.text,
                let color = noteTag.color
            else {
                return nil
            }
            return .text((text: text, color: Color(color)))
        case 2:
            guard
                let date = noteTag.date,
                let template = noteTag.template
            else {
                return nil
            }
            return .date((date: date, template: template))
        default:
            return nil
        }
    }
    
    private static func convert(_ tag: NoteModel.Tag) -> NoteTag {
        let noteTag = NoteTag(context: viewContext)
        switch tag {
        case .text((let text, let color)):
            noteTag.type = 1
            noteTag.text = text
            noteTag.color = String(color)
        case .date((let date, let template)):
            noteTag.type = 2
            noteTag.date = date
            noteTag.template = template
        }
        return noteTag
    }
    
    private static func convert(_ note: Note) -> NoteModel {
        let tags = note.tags as? Set<NoteTag> ?? []
        return NoteModel(
            id: note.uuid ?? "",
            text: note.text ?? "",
            tags: tags.compactMap { convert($0) }.sorted()
        )
    }
    
    static func deleteNote(id: String) async {
        await MainActor.run {
            let request = NSFetchRequest<Note>(entityName: "Note")
            request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [id])
            if let note = (try? viewContext.fetch(request))?.first {
                viewContext.delete(note)
            }
        }
        await MainActor.run {
            let request = NSFetchRequest<DayReport>(entityName: "DayReport")
            request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [id])
            if let note = (try? viewContext.fetch(request))?.first {
                viewContext.delete(note)
            }
        }
        await MainActor.run {
            guard
                let uri = URL(string: id),
                uri.scheme == "x-coredata",
                let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: uri)
            else {
                return
            }
            let request = NSFetchRequest<MonthReport>(entityName: "MonthReport")
            request.predicate = NSPredicate(format: "(objectID = %@)", argumentArray: [id])
            if let note = (try? viewContext.fetch(request))?.first {
                viewContext.delete(note)
            }
        }
        await MainActor.run {
            try? viewContext.save()
        }
    }
    
    static func update(_ noteModel: NoteModel) async {
        await MainActor.run {
            let request = NSFetchRequest<DayReport>(entityName: "DayReport")
            request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [noteModel.id])
            if let note = (try? viewContext.fetch(request))?.first {
                viewContext.delete(note)
            }
        }
        await MainActor.run {
            guard
                let uri = URL(string: noteModel.id),
                uri.scheme == "x-coredata",
                let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: uri)
            else {
                return
            }
            let request = NSFetchRequest<MonthReport>(entityName: "MonthReport")
            request.predicate = NSPredicate(format: "(objectID = %@)", argumentArray: [id])
            if let note = (try? viewContext.fetch(request))?.first {
                viewContext.delete(note)
            }
        }
        await MainActor.run {
            try? viewContext.save()
        }
        var note: Note? = nil
        await MainActor.run {
            let request = NSFetchRequest<Note>(entityName: "Note")
            request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [noteModel.id])
            note = (try? viewContext.fetch(request))?.first
        }
        if let note {
            await updateNote(note, noteModel: noteModel)
        } else {
            await add(noteModel)
        }
    }
}
