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
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
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
}
