import SwiftUI

struct TasksView<DI: DIProtocol>: View {
    @StateObject private var viewModel = TasksViewModel<DI>()
    @EnvironmentObject private var interactor: DI.TasksInteractorType
    @EnvironmentObject private var appState: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            TaskListView<DI>()
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button(action: viewModel.showPreviousDay) {
                            Image(systemName: "arrowtriangle.left")
                        }
                        Button(action: showSelectDateSheet) {
                            if isMac || horizontalSizeClass == .compact {
                                Text(viewModel.date.string)
                                    .monospaced()
                            } else {
                                Text(viewModel.date.shortString)
                            }
                        }
                        Button(action: viewModel.showNextDay) {
                            Image(systemName: "arrowtriangle.right")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: showAddTaskSheet) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.isSelectDateSheetVisible) {
            TasksSelectDateSheet<DI>()
        }
        .sheet(isPresented: $viewModel.isAddTaskSheetVisible) {
            AddTaskSheet<DI>(date: viewModel.date)
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.interactor = interactor
            viewModel.update()
        }
        .onReceive(interactor.objectWillChange) { _ in
            viewModel.update()
        }
        .onReceive(appState.didBecomeActiveNotification) { _ in
            viewModel.swithToNewDayIfNeeded()
        }
    }
}

extension TasksView {
    private func showSelectDateSheet() {
        viewModel.isSelectDateSheetVisible = true
    }
    
    private func showAddTaskSheet() {
        viewModel.isAddTaskSheetVisible = true
    }
}
