import SwiftUI

protocol DIProtocol {
    associatedtype TasksInteractorType: TasksInteractor
    associatedtype NotesInteractorType: NotesInteractor
}

class DIContainer<DI: DIProtocol>: ObservableObject {
    @Published var appState: AppState
    @Published var tasksInteractor: DI.TasksInteractorType
    @Published var notesInteractor: DI.NotesInteractorType
    
    init(
        appState: AppState,
        tasksInteractor: DI.TasksInteractorType,
        notesInteractor: DI.NotesInteractorType
    ) {
        _appState = .init(wrappedValue: appState)
        _tasksInteractor = .init(wrappedValue: tasksInteractor)
        _notesInteractor = .init(wrappedValue: notesInteractor)
    }
}

struct MockDI: DIProtocol {
    typealias TasksInteractorType = MockTasksInteractor
    typealias NotesInteractorType = MockNotesInteractor
}

struct RealDI: DIProtocol {
    typealias TasksInteractorType = RealTasksInteractor
    typealias NotesInteractorType = RealNotesInteractor
}

class DIBuilder<DI: DIProtocol> {
    static func build() -> DIContainer<DI> {
        if DI.self == RealDI.self {
            return real() as! DIContainer<DI>
        }
        
        if DI.self == MockDI.self {
            return mock() as! DIContainer<DI>
        }
        
        fatalError("build method does not exist for \(DI.self)")
    }
    
    static func real() -> DIContainer<RealDI> {
        let appState = AppState()
        let tasksRepository = RealTasksRepository()
        let tasksInteractor = RealDI.TasksInteractorType(repository: tasksRepository)
        let notesRepository = RealNotesRepository()
        let notesInteractor = RealDI.NotesInteractorType(repository: notesRepository)
        return DIContainer(
            appState: appState, 
            tasksInteractor: tasksInteractor,
            notesInteractor: notesInteractor
        )
    }
    
    static func mock() -> DIContainer<MockDI> {
        let appState = AppState()
        let tasksRepository = MockTasksRepository()
        let tasksInteractor = MockDI.TasksInteractorType(repository: tasksRepository)
        let notesRepository = MockNotesRepository()
        let notesInteractor = MockDI.NotesInteractorType(repository: notesRepository)
        return DIContainer(
            appState: appState,
            tasksInteractor: tasksInteractor,
            notesInteractor: notesInteractor
        )
    }
}
