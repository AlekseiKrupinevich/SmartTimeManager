import SwiftUI

struct ApplyFiltersSheet<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: NotesViewModel<DI>
    @EnvironmentObject private var notesInteractor: DI.NotesInteractorType
    @EnvironmentObject private var logsInteractor: DI.LogsInteractorType
    @State private var filterType = 1
    @State private var tags: [NoteTagViewModel] = []
    @State private var selectedTagId = ""
    @State private var dateFormat = 1
    @State private var isFromEnabled = false
    @State private var isToEnabled = false
    @State private var fromDate = Date().withoutTime
    @State private var toDate = Date().withoutTime
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Filters")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: hide) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: apply) {
                            Text("Apply")
                        }
                    }
                }
                .interactiveDismissDisabled()
                .onAppear {
                    tags = notesInteractor.tags()
                        .filter {
                            switch $0 {
                            case .text(_):
                                return true
                            case .date(_):
                                return false
                            }
                        }
                        .map {
                            NoteTagViewModel(tag: $0)
                        }
                    switch viewModel.filters.appliedFilter {
                    case nil:
                        filterType = 1
                    case .byTag(let text):
                        filterType = 2
                        selectedTagId = tags.first { $0.text == text }?.id ?? ""
                    case .byDate(let dateFilter):
                        filterType = 3
                        switch dateFilter.template {
                        case .monthTemplete:
                            dateFormat = 2
                        case .yearTemplete:
                            dateFormat = 3
                        default:
                            dateFormat = 1
                        }
                        if let from = dateFilter.from {
                            isFromEnabled = true
                            fromDate = from
                        }
                        if let to = dateFilter.to {
                            isToEnabled = true
                            toDate = to
                        }
                    case .withoutTags:
                        filterType = 4
                    }
                }
        }
    }
    
    var content: some View {
        List {
            Picker("Filter type", selection: $filterType) {
                Text("No filters")
                    .tag(1)
                Text("By tag")
                    .tag(2)
                Text("By date")
                    .tag(3)
                Text("Without tags")
                    .tag(4)
            }
            if filterType == 2 {
                Picker("Tag", selection: $selectedTagId) {
                    ForEach(tags) { tag in
                        Text(tag.text)
                            .tag(tag.id)
                    }
                }
            }
            if filterType == 3 {
                Picker("Date format", selection: $dateFormat) {
                    Text("Days")
                        .tag(1)
                    Text("Months")
                        .tag(2)
                    Text("Years")
                        .tag(3)
                }
                VStack {
                    Toggle("From", isOn: $isFromEnabled)
                    if isFromEnabled {
                        DatePicker("Date", selection: $fromDate, displayedComponents: .date)
                    }
                }
                VStack {
                    Toggle("To", isOn: $isToEnabled)
                    if isToEnabled {
                        DatePicker("Date", selection: $toDate, displayedComponents: .date)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

extension ApplyFiltersSheet {
    private func hide() {
        viewModel.isApplyFiltersSheetVisible = false
    }
    
    private func apply() {
        switch filterType {
        case 2:
            let text = tags.first { $0.id == selectedTagId }?.text ?? ""
            viewModel.filters.appliedFilter = .byTag(text)
        case 3:
            let template: String
            switch dateFormat {
            case 2:
                template = .monthTemplete
            case 3:
                template = .yearTemplete
            default:
                template = .dayTemplete
            }
            let from: Date? = isFromEnabled ? fromDate : nil
            let to: Date? = isToEnabled ? toDate : nil
            viewModel.filters.appliedFilter = .byDate(
                .init(template: template, from: from, to: to)
            )
        case 4:
            viewModel.filters.appliedFilter = .withoutTags
        default:
            viewModel.filters.appliedFilter = nil
        }
        viewModel.update()
        logsInteractor.logNoteEvent(.applyFilters)
        hide()
    }
}
