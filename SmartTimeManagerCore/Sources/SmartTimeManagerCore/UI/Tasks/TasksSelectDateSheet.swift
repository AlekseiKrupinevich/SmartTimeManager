import SwiftUI

struct TasksSelectDateSheet<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: TasksViewModel<DI>
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date".localized,
                    selection:$date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                Button(action: selectToday) {
                    Text("Select Today".localized)
                }
                Spacer()
            }
            .padding(5)
            .navigationTitle("Select Date".localized)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(action: hide) {
                        Text("Cancel".localized)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: selectDate) {
                        Text("Select".localized)
                    }
                }
            }
        }
        .onAppear {
            date = viewModel.date
        }
    }
}

extension TasksSelectDateSheet {
    private func hide() {
        viewModel.isSelectDateSheetVisible = false
    }
    
    private func selectDate() {
        viewModel.selectDate(date: date)
    }
    
    private func selectToday() {
        viewModel.selectDate(date: Date())
    }
}
