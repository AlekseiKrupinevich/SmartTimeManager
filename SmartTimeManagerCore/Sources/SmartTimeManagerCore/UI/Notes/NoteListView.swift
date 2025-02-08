import SwiftUI

struct NoteListView<DI: DIProtocol>: View {
    @EnvironmentObject private var viewModel: NotesViewModel<DI>
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink(destination: NoteDetailView<DI>(id: item.id)) {
                    NoteListItemView<DI>(itemViewModel: item)
                        .contextMenu {
                            Button(action: { viewModel.deleteNote(id: item.id) }) {
                                Text("Delete")
                            }
                        }
                }
            }
            .onDelete(perform: viewModel.deleteNotes)
        }
        .listStyle(PlainListStyle())
    }
}
