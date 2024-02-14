import Foundation
import Combine

class TasksViewModel: ObservableObject {
    @Published var date = Date().withoutTime
    @Published var items: [TaskListItemViewModel] = []
    @Published var updateItemsDate = Date().withoutTime
    @Published var isSelectDateSheetVisible = false
    @Published var isAddTaskSheetVisible = false
}
