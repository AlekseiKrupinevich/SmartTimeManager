import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var viewModel: TasksViewModel
    @EnvironmentObject private var interactor: TasksInteractor
    
    var body: some View {
        NavigationView {
            TaskListView()
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: interactor.showPreviousDay) {
                            Image(systemName: "arrowtriangle.left")
                        }
                        Button(action: interactor.showSelectDateSheet) {
                            Text(viewModel.date.string)
                        }
                        Button(action: interactor.showNextDay) {
                            Image(systemName: "arrowtriangle.right")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: interactor.showAddTaskSheet) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.isSelectDateSheetVisible) {
            TasksSelectDateSheet()
        }
        .sheet(isPresented: $viewModel.isAddTaskSheetVisible) {
            AddTaskSheet(date: viewModel.date)
        }
    }
}
