import CoreData

@available(iOS 15.0, *)
@available(macOS 13.0, *)
public struct CoreDataWrapper {
    private nonisolated(unsafe) static var container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "CoreDataModel")
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
    
    public static func task(id: String) -> Task? {
        let request = NSFetchRequest<Task>(entityName: "Task")
        request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [id])
        let fetchResult = try? viewContext.fetch(request)
        return fetchResult?.first
    }
    
    public static func tasks() -> [Task] {
        let request = NSFetchRequest<Task>(entityName: "Task")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createDate, ascending: true)]
        let fetchResult = try? viewContext.fetch(request)
        return fetchResult ?? []
    }
}
