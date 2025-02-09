protocol NotesRepository {
    func notes() -> [NoteModel]
    func note(id: String) -> NoteModel?
    func add(note: NoteModel)
    func update(note: NoteModel)
    func deleteNote(id: String)
    func subscribe(onUpdate: @escaping () -> Void)
}
