import SwiftUI

struct AddNoteSheet<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: NotesViewModel<DI>
    @EnvironmentObject private var interactor: DI.NotesInteractorType
    @State private var note = NoteModel()
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            EditNoteView(note: $note, needFocusOnText: true)
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
            try interactor.validate(note)
            interactor.add(note)
            hide()
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
}
