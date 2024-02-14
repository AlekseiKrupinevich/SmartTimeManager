import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject private var interactor: TasksInteractor
    @State private var task: TaskModel
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    init(date: Date) {
        _task = State<TaskModel>.init(initialValue: TaskModel(date: date))
    }
    
    var body: some View {
        NavigationView {
            EditTaskView(task: $task)
                .navigationTitle("Add Task")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: interactor.hideAddTaskSheet) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                do {
                                    try interactor.validate(task)
                                    interactor.addTask(task)
                                } catch {
                                    alertTitle = "\(error)"
                                    isAlertPresented = true
                                }
                            },
                            label: {
                                Text("Add")
                            }
                        )
                    }
                }
                .interactiveDismissDisabled()
                .alert(alertTitle, isPresented: $isAlertPresented, actions: {})
        }
    }
}
