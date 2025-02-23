import SwiftUI

struct CreateDateTagSheet: View {
    let cancel: () -> Void
    let create: (_ date: Date, _ template: String) -> Void
    @State private var date = Date().withoutTime
    @State private var template = String.dayTemplete
    
    var body: some View {
        NavigationView {
            List {
                typePicker
                if template == .dayTemplete {
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                } else {
                    if template == .monthTemplete {
                        monthPicker
                    }
                    yearPicker
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Date Tag")
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: didTapCreateButton) {
                        Text("Create")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func didTapCreateButton() {
        if template == .monthTemplete {
            create(date.firstDayOfMonth, template)
        } else if template == .yearTemplete {
            create(date.firstDayOfYear, template)
        } else {
            create(date, template)
        }
    }
    
    private var typePicker: some View {
        Picker(
            selection: $template,
            content: {
                Text("Day")
                    .tag(String.dayTemplete)
                Text("Month")
                    .tag(String.monthTemplete)
                Text("Year")
                    .tag(String.yearTemplete)
            },
            label: {
                Text("Type")
            }
        )
    }
    
    private var month: Binding<Int> {
        Binding<Int>(
            get: {
                date.month
            },
            set: {
                date.month = $0
            }
        )
    }
    
    private var monthPicker: some View {
        Picker(
            selection: month,
            content: {
                Text("January").tag(1)
                Text("Febrary").tag(2)
                Text("March").tag(3)
                Text("April").tag(4)
                Text("May").tag(5)
                Text("June").tag(6)
                Text("July").tag(7)
                Text("August").tag(8)
                Text("September").tag(9)
                Text("October").tag(10)
                Text("November").tag(11)
                Text("December").tag(12)
            },
            label: {
                Text("Month")
            }
        )
    }
    
    private var year: Binding<Int> {
        Binding<Int>(
            get: {
                date.year
            },
            set: {
                date.year = $0
            }
        )
    }
    
    private var yearPicker: some View {
        Picker(
            selection: year,
            content: {
                ForEach(2000 ..< 2100) { year in
                    Text(String(year)).tag(year)
                }
            },
            label: {
                Text("Year")
            }
        )
    }
}
