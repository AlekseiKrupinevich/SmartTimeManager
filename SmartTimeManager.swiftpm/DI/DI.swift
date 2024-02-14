enum DI {
    typealias BuildResult = (
        appState: AppState,
        tasksViewModel: TasksViewModel,
        tasksInteractor: TasksInteractor
    )
    
    static func build() -> BuildResult {
        mock()
    }
    
    private static func real() -> BuildResult {
        let tasksViewModel = TasksViewModel()
        let tasksRepository = RealTasksRepository()
        let tasksInteractor = TasksInteractor(
            viewModel: tasksViewModel,
            tasksRepository: tasksRepository)
        let appState = AppState(tasksInteractor: tasksInteractor)
        return (
            appState,
            tasksViewModel,
            tasksInteractor
        )
    }
    
    private static func mock() -> BuildResult {
        let tasksViewModel = TasksViewModel()
        let tasksRepository = MockTasksRepository()
        let tasksInteractor = TasksInteractor(
            viewModel: tasksViewModel,
            tasksRepository: tasksRepository)
        let appState = AppState(tasksInteractor: tasksInteractor)
        return (
            appState,
            tasksViewModel,
            tasksInteractor
        )
    }
}
