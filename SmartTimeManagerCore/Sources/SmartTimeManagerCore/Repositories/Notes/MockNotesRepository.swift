import SwiftUI

class MockNotesRepository: NotesRepository {
    private var _notes: [NoteModel] = [
        .init(
            id: "1",
            text: "Vestibulum quis efficitur sem, at euismod mi. Phasellus mollis ante placerat consequat pulvinar. Nam at vestibulum justo.",
            marks: [
                .text(("Todo", Color.green)),
                .text(("TODO!!!", Color.indigo)),
            ]
        ),
        .init(
            id: "2",
            text: "Nunc tempus eros et ipsum volutpat posuere. Quisque sed est sapien.\n\nInteger rhoncus massa quam, id semper nulla cursus et. Phasellus nec odio sit amet libero ornare imperdiet quis ut turpis. Etiam fermentum molestie ligula, interdum interdum dolor aliquet sed. Proin quis libero ex. Nunc id maximus orci, ac tempor dui.",
            marks: [
                .text(("Important", .red)),
                .date((Date().withoutTime, "dMMMyyy")),
                .text(("Tag 1", .blue)),
                .text(("Tag 2", .yellow)),
                .text(("Tag 3", .orange)),
                .text(("Tag 4", .purple)),
            ]
        ),
        .init(
            id: "3",
            text: "Curabitur sit amet urna mattis, aliquet est id, lobortis ante.\nQuisque sodales lacinia nibh.\nInteger vel cursus lacus, vel pulvinar neque.\nDuis tristique ante id nunc iaculis placerat.",
            marks: []
        )
    ]
    
    func notes() -> [NoteModel] {
        _notes
    }
    
    func note(id: String) -> NoteModel? {
        _notes.first { $0.id == id }
    }
    
    func add(note: NoteModel) {
        _notes.insert(note, at: 0)
    }
    
    func update(note: NoteModel) {
        guard let index = _notes.firstIndex(where: { $0.id == note.id }) else {
            return
        }
        _notes[index] = note
    }
    
    func deleteNote(id: String) {
        _notes.removeAll(where: { $0.id == id })
    }
    
    func subscribe(onUpdate: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?._notes.insert(
                .init(
                    id: UUID().uuidString,
                    text: "Maecenas sed eros elit. Fusce magna sapien, pharetra in dui sit amet, sollicitudin elementum neque. Phasellus maximus lacus maximus, pharetra nulla vel, vehicula quam.",
                    marks: []
                ),
                at: 0
            )
            onUpdate()
        }
    }
}
