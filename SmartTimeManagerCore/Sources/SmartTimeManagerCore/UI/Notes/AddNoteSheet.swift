import SwiftUI

struct AddNoteSheet<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: NotesViewModel<DI>
    @EnvironmentObject private var notesInteractor: DI.NotesInteractorType
    @EnvironmentObject private var logsInteractor: DI.LogsInteractorType
    @State private var note = NoteModel()
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            EditNoteView<DI>(note: $note, needFocusOnText: true)
                .navigationTitle("Add Note")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: hide) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: add) {
                            Text("Add")
                        }
                    }
                }
                .interactiveDismissDisabled()
                .alert(alertTitle, isPresented: $isAlertPresented, actions: {})
        }
    }
}

extension AddNoteSheet {
    private func hide() {
        viewModel.isAddNoteSheetVisible = false
    }
    
    private func add() {
        do {
            try notesInteractor.validate(note)
            notesInteractor.add(note)
            logsInteractor.logNoteEvent(.add)
            hide()
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
}
