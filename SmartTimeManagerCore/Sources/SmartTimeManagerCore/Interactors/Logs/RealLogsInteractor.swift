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
    
    private var sizeOfDatabase: Int {
        CoreDataWrapper.sizeOfDatabase()
    }
    
    private var urlSession: URLSession {
        URLSession.shared
    }
    
    private var url: URL {
        URL(string: "https://aleksei-krupinevich.com:12321/logs/v1/")!
    }
    
    private var appStartedBody: Data? {
        struct Body: Encodable {
            let instance_id: String
            let device_model: String?
            let os_version: String?
            let app_version: String?
        }
        
        let body = Body(
            instance_id: instanceId,
            device_model: deviceModel,
            os_version: osVersion,
            app_version: appVersion
        )
        
        return try? JSONEncoder().encode(body)
    }
    
    private var appDidBecomeActiveBody: Data? {
        struct Body: Encodable {
            let instance_id: String
            let number_of_tasks: Int?
            let number_of_notes: Int?
            let number_of_tags: Int?
            let size_of_database: Int?
        }
        
        let body = Body(
            instance_id: instanceId,
            number_of_tasks: numberOfTasks,
            number_of_notes: numberOfNotes,
            number_of_tags: numberOfTags,
            size_of_database: sizeOfDatabase
        )
        
        return (try? JSONEncoder().encode(body))
    }
    
    private func taskEventBody(_ taskEvent: TaskEvent) -> Data? {
        struct Body: Encodable {
            let instance_id: String
            let event: String
        }
        
        let body = Body(
            instance_id: instanceId,
            event: taskEvent.rawValue
        )
        
        return (try? JSONEncoder().encode(body))
    }
    
    private func noteEventBody(_ noteEvent: NoteEvent) -> Data? {
        struct Body: Encodable {
            let instance_id: String
            let event: String
        }
        
        let body = Body(
            instance_id: instanceId,
            event: noteEvent.rawValue
        )
        
        return (try? JSONEncoder().encode(body))
    }
    
    func logAppStarted() {
        var request = URLRequest(
            url: url.appending(component: "appStarted")
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = appStartedBody
        urlSession.dataTask(with: request).resume()
    }
    
    func logAppDidBecomeActive() {
        var request = URLRequest(
            url: url.appending(component: "appDidBecomeActive")
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = appDidBecomeActiveBody
        urlSession.dataTask(with: request).resume()
    }
    
    func logTaskEvent(_ taskEvent: TaskEvent) {
        var request = URLRequest(
            url: url.appending(component: "taskEvent")
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = taskEventBody(taskEvent)
        urlSession.dataTask(with: request).resume()
    }
    
    func logNoteEvent(_ noteEvent: NoteEvent) {
        var request = URLRequest(
            url: url.appending(component: "noteEvent")
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = noteEventBody(noteEvent)
        urlSession.dataTask(with: request).resume()
    }
}
