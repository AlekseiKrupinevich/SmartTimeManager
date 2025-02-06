import SwiftUI

protocol DIProtocol {
    associatedtype TasksInteractorType: TasksInteractor
}

class DIContainer<DI: DIProtocol>: ObservableObject {
    @Published var appState: AppState
    @Published var tasksInteractor: DI.TasksInteractorType
    
    init(
        appState: AppState,
        tasksInteractor: DI.TasksInteractorType
    ) {
        _appState = .init(wrappedValue: appState)
        _tasksInteractor = .init(wrappedValue: tasksInteractor)
    }
}

struct MockDI: DIProtocol {
    typealias TasksInteractorType = MockTasksInteractor
}

struct RealDI: DIProtocol {
    typealias TasksInteractorType = RealTasksInteractor
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
        return DIContainer(
            appState: appState, 
            tasksInteractor: tasksInteractor
        )
    }
    
    static func mock() -> DIContainer<MockDI> {
        let appState = AppState()
        let tasksRepository = MockTasksRepository()
        let tasksInteractor = MockDI.TasksInteractorType(repository: tasksRepository)
        return DIContainer(
            appState: appState,
            tasksInteractor: tasksInteractor
        )
    }
}
