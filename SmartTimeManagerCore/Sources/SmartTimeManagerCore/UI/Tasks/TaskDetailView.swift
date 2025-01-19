import SwiftUI

struct TaskDetailView<DI: DIProtocol>: View {
    @EnvironmentObject private var interactor: DI.TasksInteractorType
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
        EditTaskView(task: $task, needFocusOnTitle: false)
            .navigationTitle("Task")
            .toolbar {
                if isTaskModified {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: cancel) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: save) {
                            Text("Save")
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(isTaskModified)
            .alert(alertTitle, isPresented: $isAlertPresented, actions: {})
            .onAppear(perform: update)
            .onChange(of: task) { _, _ in
                isTaskModified = originalTask != task
            }
    }
}

extension TaskDetailView {
    private func cancel() {
        task = originalTask
        isTaskModified = false
    }
    
    private func save() {
        do {
            try interactor.validate(task)
            interactor.update(task)
            update()
            isTaskModified = false
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
    
    private func update() {
        guard let task = interactor.task(id: task.id) else {
            return
        }
        self.task = task
        originalTask = task
    }
}
