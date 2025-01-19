import SwiftUI

struct AddTaskSheet<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: TasksViewModel<DI>
    @EnvironmentObject private var interactor: DI.TasksInteractorType
    @State private var task: TaskModel
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    init(date: Date) {
        _task = State<TaskModel>.init(initialValue: TaskModel(date: date))
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
            try interactor.validate(task)
            interactor.add(task)
            hide()
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
}
