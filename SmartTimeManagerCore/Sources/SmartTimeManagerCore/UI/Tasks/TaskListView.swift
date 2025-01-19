import SwiftUI

struct TaskListView<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: TasksViewModel<DI>
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink(destination: TaskDetailView<DI>(id: item.id)) {
                    TaskListItemView<DI>(itemViewModel: item)
                        .contextMenu {
                            Button(action: { viewModel.deleteTask(id: item.id) }) {
                                Text("Delete")
                            }
                        }
                }
            }
            .onDelete(perform: viewModel.deleteTasks)
        }
        .listStyle(PlainListStyle())
    }
}
