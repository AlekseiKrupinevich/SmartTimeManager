protocol NotesRepository {
    func notes() -> [NoteModel]
    func deleteNote(id: String)
    func subscribe(onUpdate: @escaping () -> Void)
}
