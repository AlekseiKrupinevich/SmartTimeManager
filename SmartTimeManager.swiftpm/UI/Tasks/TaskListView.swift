import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var viewModel: TasksViewModel
    @EnvironmentObject private var interactor: TasksInteractor
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink(destination: TaskDetailView(id: item.id)) {
                    TaskListItemView(itemViewModel: item)
                        .contextMenu {
                            Button(action: { interactor.deleteTask(id: item.id) }) {
                                Text("Delete")
                            }
                        }
                }
            }
            .onDelete(perform: interactor.deleteTasks)
        }
        .listStyle(PlainListStyle())
    }
}
