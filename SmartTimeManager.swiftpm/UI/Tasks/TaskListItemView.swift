import SwiftUI

struct TaskListItemView: View {
    @EnvironmentObject private var interactor: TasksInteractor
    let itemViewModel: TaskListItemViewModel
    
    var body: some View {
        HStack(spacing: 5) {
            Button(action: { interactor.toggleTaskCompletion(id: itemViewModel.id) }) {
                ZStack(alignment: .center) {
                    Image(systemName: "circle")
                        .font(.system(size: 18, weight: .light))
                    if itemViewModel.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 20, weight: .regular))
                            .offset(x: 2, y: -3)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            Text(itemViewModel.title)
                .fontWeight(itemViewModel.isCompleted ? .light : .regular)
                .opacity(itemViewModel.isCompleted ? 0.5 : 1)
        }
    }
}
