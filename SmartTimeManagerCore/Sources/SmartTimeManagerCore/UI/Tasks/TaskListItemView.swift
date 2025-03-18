import SwiftUI

struct TaskListItemView<DI: DIProtocol>: View {
    let itemViewModel: TaskListItemViewModel
    @EnvironmentObject private var viewModel: TasksViewModel<DI>
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: toggleCompletion) {
                ZStack(alignment: .center) {
                    Image(systemName: "circle")
                        .font(.system(size: 18, weight: .light))
                    if itemViewModel.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 20, weight: .regular))
                            .offset(x: 2, y: -3)
                    } else if appState.settings.isNumberingDisplayed {
                        Text("\(itemViewModel.index)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
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

extension TaskListItemView {
    private func toggleCompletion() {
        viewModel.toggleTaskCompletion(id: itemViewModel.id)
    }
}
