import SwiftUI

struct NoteDetailView<DI: DIProtocol>: View {
    @EnvironmentObject private var notesInteractor: DI.NotesInteractorType
    @EnvironmentObject private var logsInteractor: DI.LogsInteractorType
    @State private var note: NoteModel
    @State private var originalNote: NoteModel
    @State private var isNoteModified = false
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    init(id: String) {
        let note = NoteModel(id: id)
        _note = State<NoteModel>(initialValue: note)
        _originalNote = State<NoteModel>(initialValue: note)
    }
    
    var body: some View {
        EditNoteView<DI>(note: $note, needFocusOnText: false)
            .navigationTitle("Note")
            .toolbar {
                if isNoteModified {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: cancel) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: save) {
                            Text("Save")
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(isNoteModified)
            .alert(alertTitle, isPresented: $isAlertPresented, actions: {})
            .onAppear(perform: update)
            .onChange(of: note) { _, _ in
                isNoteModified = originalNote != note
            }
    }
}

extension NoteDetailView {
    private func cancel() {
        note = originalNote
        isNoteModified = false
    }
    
    private func save() {
        do {
            try notesInteractor.validate(note)
            notesInteractor.update(note)
            logsInteractor.logNoteEvent(.edit)
            update()
            isNoteModified = false
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
    
    private func update() {
        guard let note = notesInteractor.note(id: note.id) else {
            return
        }
        self.note = note
        originalNote = note
    }
}
