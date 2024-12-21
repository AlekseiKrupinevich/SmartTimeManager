import SwiftUI

struct TasksSelectDateSheet<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: TasksViewModel<DI>
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection:$date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                Button(action: selectToday) {
                    Text("Select Today")
                }
                Spacer()
            }
            .padding(5)
            .navigationTitle("Select Date")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: hide) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: selectDate) {
                        Text("Select")
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
