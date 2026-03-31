import SwiftUI

struct NotesView<DI: DIProtocol>: View {
    @StateObject private var viewModel = NotesViewModel<DI>()
    @EnvironmentObject private var notesInteractor: DI.NotesInteractorType
    @EnvironmentObject private var logsInteractor: DI.LogsInteractorType
    
    var body: some View {
        NavigationView {
            NoteListView<DI>()
                .navigationTitle("Notes".localized)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: showApplyFiltersSheet) {
                            if viewModel.filters.appliedFilter != nil {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Image(systemName: "line.3.horizontal.decrease")
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
            viewModel.notesInteractor = notesInteractor
            viewModel.logsInteractor = logsInteractor
            viewModel.update()
        }
        .onReceive(notesInteractor.objectWillChange) { _ in
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
