struct NoteListItemViewModel: Identifiable {
    let id: String
    let text: String
    let tags: [NoteTagViewModel]
}
