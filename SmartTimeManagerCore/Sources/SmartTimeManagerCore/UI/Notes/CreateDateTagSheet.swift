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
                        "Date".localized,
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
            .navigationTitle("Date Tag".localized)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel".localized)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: didTapCreateButton) {
                        Text("Create".localized)
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
                Text("Day".localized)
                    .tag(String.dayTemplete)
                Text("Month".localized)
                    .tag(String.monthTemplete)
                Text("Year".localized)
                    .tag(String.yearTemplete)
            },
            label: {
                Text("Type".localized)
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
                Text("January".localized).tag(1)
                Text("Febrary".localized).tag(2)
                Text("March".localized).tag(3)
                Text("April".localized).tag(4)
                Text("May".localized).tag(5)
                Text("June".localized).tag(6)
                Text("July".localized).tag(7)
                Text("August".localized).tag(8)
                Text("September".localized).tag(9)
                Text("October".localized).tag(10)
                Text("November".localized).tag(11)
                Text("December".localized).tag(12)
            },
            label: {
                Text("Month".localized)
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
                Text("Year".localized)
            }
        )
    }
}
