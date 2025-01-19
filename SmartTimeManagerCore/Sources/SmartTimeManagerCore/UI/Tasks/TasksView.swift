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
                    ToolbarItemGroup(placement: leadingToolbarPlacement) {
                        Button(action: viewModel.showPreviousDay) {
                            Image(systemName: "arrowtriangle.left")
                        }
                        Button(action: showSelectDateSheet) {
                            switch horizontalSizeClass {
                            case .regular:
                                Text(viewModel.date.shortString)
                            case .compact, nil:
                                Text(viewModel.date.string)
                                    .monospaced()
                            }
                        }
                        Button(action: viewModel.showNextDay) {
                            Image(systemName: "arrowtriangle.right")
                        }
                    }
                    ToolbarItem(placement: trailingToolbarPlacement) {
                        Button(action: showAddTaskSheet) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .navigationViewStyle(navigationViewStyle)
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
    
    private var leadingToolbarPlacement: ToolbarItemPlacement {
#if canImport(UIKit)
        return ToolbarItemPlacement.topBarLeading
#else
        return ToolbarItemPlacement.automatic
#endif
    }
    
    private var trailingToolbarPlacement: ToolbarItemPlacement {
#if canImport(UIKit)
        return ToolbarItemPlacement.topBarTrailing
#else
        return ToolbarItemPlacement.automatic
#endif
    }
    
    private var navigationViewStyle: some NavigationViewStyle {
#if canImport(UIKit)
        return StackNavigationViewStyle()
#else
        return DefaultNavigationViewStyle()
#endif
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
