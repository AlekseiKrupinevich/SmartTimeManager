import SwiftUI

class RealLogsInteractor: LogsInteractor {
    private let tasksRepository: any TasksRepository
    private let notesRepository: any NotesRepository
    
    @AppStorage("instanceId")
    private var instanceId = ""
    
    init(
        tasksRepository: any TasksRepository,
        notesRepository: any NotesRepository
    ) {
        self.tasksRepository = tasksRepository
        self.notesRepository = notesRepository
        if instanceId.isEmpty {
            instanceId = UUID().uuidString
        }
    }
    
    private var deviceModel: String {
        UIDevice.isMac ? "Mac" : UIDevice.current.model
    }
    
    private var osVersion: String {
        "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.patchVersion)"
    }
    
    private var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private var numberOfTasks: Int {
        tasksRepository.tasks().count
    }
    
    private var numberOfNotes: Int {
        notesRepository.notes().count
    }
    
    private var numberOfTags: Int {
        notesRepository.tags().count
    }
    
    private var size_of_database: Int {
        CoreDataWrapper.sizeOfDatabase()
    }
    
    func logAppStarted() {
        print("Log: App started")
        print("    instance_id: \(instanceId)")
        print("    device_model: \(deviceModel)")
        print("    os_version: \(osVersion)")
        print("    app_version: \(appVersion ?? "")")
    }
    
    func logAppDidBecomeActive() {
        print("Log: App did become active")
        print("    number_of_tasks: \(numberOfTasks)")
        print("    number_of_notes: \(numberOfNotes)")
        print("    number_of_tags: \(numberOfTags)")
        print("    size_of_database: \(size_of_database)")
    }
    
    func logTaskEvent(_ taskEvent: TaskEvent) {
        print("Log: Task event occurred <\(taskEvent.rawValue)>")
    }
    
    func logNoteEvent(_ noteEvent: NoteEvent) {
        print("Log: Note event occurred <\(noteEvent.rawValue)>")
    }
}
