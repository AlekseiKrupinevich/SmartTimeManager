import SwiftUI

struct TasksSelectDateSheet: View {
    @EnvironmentObject private var viewModel: TasksViewModel
    @EnvironmentObject private var interactor: TasksInteractor
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
                Button(action: { interactor.selectDate(date: Date()) }) {
                    Text("Select Today")
                }
                Spacer()
            }
            .padding(5)
            .navigationTitle("Select Date")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: interactor.hideSelectDateSheet) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { interactor.selectDate(date: date)}) {
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
