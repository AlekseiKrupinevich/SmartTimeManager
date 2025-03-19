import SwiftUI

struct AddTaskSheet<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: TasksViewModel<DI>
    @EnvironmentObject private var tasksInteractor: DI.TasksInteractorType
    @EnvironmentObject private var logsInteractor: DI.LogsInteractorType
    @State private var task: TaskModel
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    init(date: Date) {
        _task = State<TaskModel>(initialValue: TaskModel(date: date))
    }
    
    var body: some View {
        NavigationView {
            EditTaskView(task: $task, needFocusOnTitle: true)
                .navigationTitle("Add Task")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: hide) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: add) {
                            Text("Add")
                        }
                    }
                }
                .interactiveDismissDisabled()
                .alert(alertTitle, isPresented: $isAlertPresented, actions: {})
        }
    }
}

extension AddTaskSheet {
    private func hide() {
        viewModel.isAddTaskSheetVisible = false
    }
    
    private func add() {
        do {
            try tasksInteractor.validate(task)
            tasksInteractor.add(task)
            logsInteractor.logTaskEvent(.add)
            hide()
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
}
