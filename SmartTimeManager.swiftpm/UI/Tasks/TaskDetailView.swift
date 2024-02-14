import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject private var interactor: TasksInteractor
    @State private var task: TaskModel
    @State private var originalTask: TaskModel
    @State private var isTaskModified = false
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    init(id: String) {
        let task = TaskModel(id: id)
        _task = State<TaskModel>.init(initialValue: task)
        _originalTask = State<TaskModel>.init(initialValue: task)
    }
    
    var body: some View {
        EditTaskView(task: $task)
            .navigationTitle("Task")
            .toolbar {
                if isTaskModified {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(
                            action: {
                                task = originalTask
                                isTaskModified = false
                            },
                            label: {
                                Text("Cancel")
                            }
                        )
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                do {
                                    try interactor.validate(task)
                                    interactor.update(task)
                                    reloadTask()
                                    isTaskModified = false
                                } catch {
                                    alertTitle = "\(error)"
                                    isAlertPresented = true
                                }
                            },
                            label: {
                                Text("Save")
                            }
                        )
                    }
                }
            }
            .navigationBarBackButtonHidden(isTaskModified)
            .alert(alertTitle, isPresented: $isAlertPresented, actions: {})
            .onAppear(perform: reloadTask)
            .onChange(of: task) { _, _ in
                isTaskModified = originalTask != task
            }
    }
    
    private func reloadTask() {
        if let task = interactor.task(id: task.id) {
            self.task = task
            self.originalTask = task
        }
    }
}
