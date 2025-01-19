import SwiftUI

struct EditTaskView: View {
    @Binding var task: TaskModel
    let needFocusOnTitle: Bool
    @FocusState private var focused
    
    var body: some View {
        List {
            title
                .focused($focused)
            notes
            typePicker
            switch task.type {
            case .oneTime(let oneTime):
                oneTimeDatePicker(oneTime)
            case .periodic(let periodic):
                timeFrameToggle(periodic)
                if case let .on(timeFrame) = periodic.timeFrame {
                    startDatePicker(periodic: periodic, timeFrame: timeFrame)
                    endDatePicker(periodic: periodic, timeFrame: timeFrame)
                }
                periodicTypePicker(periodic)
                if case let .weekly(days) = periodic.type {
                    weekdaysPicker(periodic: periodic, days: days)
                }
                if case let .monthly(days) = periodic.type {
                    monthdaysPicker(periodic: periodic, days: days)
                }
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            if needFocusOnTitle {
                focused = true
            }
        }
    }
    
    private var title: some View {
        textEditor(text: $task.title, placeholder: "Title")
    }
    
    private var notes: some View {
        textEditor(text: $task.notes, placeholder: "Notes")
    }
    
    private func textEditor(text: Binding<String>, placeholder: String) -> some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: text)
                .overlay(alignment: .topLeading) {
                    Text(placeholder)
                        .allowsHitTesting(false)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .foregroundColor(text.wrappedValue.isEmpty ? .secondary : .clear)
                }
            // MARK: It fixes TextEditor default height
            Text(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                .padding(EdgeInsets(top: 8, leading: 5, bottom: 10, trailing: 5))
                .foregroundColor(.clear)
                .allowsHitTesting(false)
        }
    }
    
    private var typePicker: some View {
        Picker(
            selection: Binding(
                get: { () -> Int in
                    switch task.type {
                    case .oneTime(_):
                        return 1
                    case .periodic(_):
                        return 2
                    }
                }, set: {
                    switch $0 {
                    case 1:
                        task.type = .oneTime(.init(date: Date().withoutTime))
                    case 2:
                        task.type = .periodic(
                            .init(
                                timeFrame: .off,
                                type: .everyday
                            )
                        )
                    default:
                        break
                    }
                }
            ),
            content: {
                Text("One-time")
                    .tag(1)
                Text("Periodic")
                    .tag(2)
            },
            label: { }
        )
        .pickerStyle(SegmentedPickerStyle())
        .fixedSize()
        .padding(.vertical, 5)
    }
    
    private func oneTimeDatePicker(_ oneTime: TaskModel.TaskType.OneTime) -> some View {
        DatePicker(
            selection: Binding(
                get: { 
                    return oneTime.date
                },
                set: {
                    var updatedOneTime = oneTime
                    updatedOneTime.date = $0.withoutTime
                    task.type = .oneTime(updatedOneTime)
                }
            ),
            displayedComponents: .date,
            label: { Text("Date") }
        )
        .datePickerStyle(.compact)
        .fixedSize()
        .padding(.vertical, 5)
    }
    
    private func timeFrameToggle(_ periodic: TaskModel.TaskType.Periodic) -> some View {
        Toggle("Time Frame", isOn: Binding(
            get: {
                if case .off = periodic.timeFrame {
                    return false
                }
                return true
            },
            set: {
                var updatedPeriodic = periodic
                if $0 {
                    updatedPeriodic.timeFrame = .on(
                        .init(
                            startDate: Date().withoutTime,
                            endDate: Date().withoutTime
                        )
                    )
                } else {
                    updatedPeriodic.timeFrame = .off
                }
                task.type = .periodic(updatedPeriodic)
            }
        ))
        .fixedSize()
        .padding(.vertical, 5)
    }
    
    private func startDatePicker(periodic: TaskModel.TaskType.Periodic, timeFrame: TaskModel.TaskType.Periodic.TimeFrame.On) -> some View {
        DatePicker(
            selection: Binding(
                get: { 
                    return timeFrame.startDate
                },
                set: {
                    var updatedPeriodic = periodic
                    var updatedTimeFrame = timeFrame
                    updatedTimeFrame.startDate = $0.withoutTime
                    if updatedTimeFrame.endDate < updatedTimeFrame.startDate {
                        updatedTimeFrame.endDate = updatedTimeFrame.startDate
                    } 
                    updatedPeriodic.timeFrame = .on(updatedTimeFrame)
                    task.type = .periodic(updatedPeriodic)
                }
            ),
            displayedComponents: .date,
            label: { Text("Start Date") }
        )
        .datePickerStyle(.compact)
        .fixedSize()
        .padding(.vertical, 5)
    }
    
    private func endDatePicker(periodic: TaskModel.TaskType.Periodic, timeFrame: TaskModel.TaskType.Periodic.TimeFrame.On) -> some View {
        DatePicker(
            selection: Binding(
                get: { 
                    return timeFrame.endDate
                },
                set: {
                    var updatedPeriodic = periodic
                    var updatedTimeFrame = timeFrame
                    updatedTimeFrame.endDate = $0.withoutTime
                    updatedPeriodic.timeFrame = .on(updatedTimeFrame)
                    task.type = .periodic(updatedPeriodic)
                }
            ),
            in: timeFrame.startDate...,
            displayedComponents: .date,
            label: { Text("End Date") }
        )
        .datePickerStyle(.compact)
        .fixedSize()
        .padding(.vertical, 5)
    }
    
    private func periodicTypePicker(_ periodic: TaskModel.TaskType.Periodic) -> some View {
        Picker(
            selection: Binding(
                get: { () -> Int in
                    switch periodic.type {
                    case .everyday:
                        return 1
                    case .weekly(_):
                        return 2
                    case .monthly(_):
                        return 3
                    case .lastDayOfMonth:
                        return 4
                    }
                }, set: {
                    var updatedPeriodic = periodic
                    switch $0 {
                    case 1:
                        updatedPeriodic.type = .everyday
                    case 2:
                        updatedPeriodic.type = .weekly([])
                    case 3:
                        updatedPeriodic.type = .monthly([])
                    case 4:
                        updatedPeriodic.type = .lastDayOfMonth
                    default:
                        task.type = .periodic(
                            .init(
                                timeFrame: .off,
                                type: .everyday
                            )
                        )
                    }
                    task.type = .periodic(updatedPeriodic)
                }
            ),
            content: {
                Text("Everyday")
                    .tag(1)
                Text("Weekly")
                    .tag(2)
                Text("Monthly")
                    .tag(3)
                Text("Last day of the month")
                    .tag(4)
            },
            label: { Text("Period Type") }
        )
        .fixedSize()
        .padding(.vertical, 5)
    }
    
    private func weekdaysPicker(periodic: TaskModel.TaskType.Periodic, days: Set<Int>) -> some View {
        LazyVGrid(
            columns: [.init(
                .adaptive(minimum: 60),
                spacing: 0,
                alignment: .center
            )]
        ) {
            ForEach(Date.weekdays, id: \.day) { weekday in
                Toggle(
                    isOn: Binding(
                        get: {
                            days.contains(weekday.day)
                        },
                        set: { isOn in
                            var days = days
                            if isOn {
                                days.insert(weekday.day)
                            } else {
                                days.remove(weekday.day)
                            }
                            var updatedPeriodic = periodic
                            updatedPeriodic.type = .weekly(days)
                            task.type = .periodic(updatedPeriodic)
                        }
                    ),
                    label: {
                        Text(weekday.shortSymbol)
                    }
                )
                .toggleStyle(ButtonToggleStyle())
                .monospaced()
            }
        }
    }
    
    private func monthdaysPicker(periodic: TaskModel.TaskType.Periodic, days: Set<Int>) -> some View {
        LazyVGrid(
            columns: [.init(
                .adaptive(minimum: 50),
                spacing: 0,
                alignment: .center
            )]
        ) {
            ForEach(1 ..< 32, id: \.self) { day in
                Toggle(
                    isOn: Binding(
                        get: {
                            days.contains(day)
                        },
                        set: { isOn in
                            var days = days
                            if isOn {
                                days.insert(day)
                            } else {
                                days.remove(day)
                            }
                            var updatedPeriodic = periodic
                            updatedPeriodic.type = .monthly(days)
                            task.type = .periodic(updatedPeriodic)
                        }
                    ),
                    label: {
                        Text("\(day)")
                    }
                )
                .toggleStyle(ButtonToggleStyle())
                .monospacedDigit()
            }
        }
    }
}
