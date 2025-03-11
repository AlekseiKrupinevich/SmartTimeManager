import SwiftUI

struct NotesView<DI: DIProtocol>: View {
    @StateObject private var viewModel = NotesViewModel<DI>()
    @EnvironmentObject private var interactor: DI.NotesInteractorType
    
    var body: some View {
        NavigationView {
            NoteListView<DI>()
                .navigationTitle("Notes")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        let filter = viewModel.filters.appliedFilter
                        Button(action: showApplyFiltersSheet) {
                            Image(systemName: "line.3.horizontal.decrease")
                            if let filter {
                                Text(filter.text)
                                    .foregroundStyle(filter.color)
                            } else {
                                Text("No filters")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: showAddNoteSheet) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.isApplyFiltersSheetVisible) {
            ApplyFiltersSheet<DI>()
        }
        .sheet(isPresented: $viewModel.isAddNoteSheetVisible) {
            AddNoteSheet<DI>()
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.interactor = interactor
            viewModel.update()
        }
        .onReceive(interactor.objectWillChange) { _ in
            viewModel.update()
        }
    }
}

extension NotesView {
    private func showApplyFiltersSheet() {
        viewModel.isApplyFiltersSheetVisible = true
    }
    
    private func showAddNoteSheet() {
        viewModel.isAddNoteSheetVisible = true
    }
}
