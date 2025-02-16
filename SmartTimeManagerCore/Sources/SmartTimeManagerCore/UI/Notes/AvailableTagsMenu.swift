import SwiftUI

struct AvailableTagsMenu<DI: DIProtocol>: View {
    @EnvironmentObject var viewModel: NoteTagsViewModel<DI>
    let createNewTag: () -> Void
    
    var body: some View {
        Menu(
            content: {
                HStack {
                    Menu(
                        content: {
                            ForEach(viewModel.availableDateTags, id: \.self) { text in
                                Button(action: { }) {
                                    Text(text)
                                }
                            }
                        },
                        label: {
                            Label("Date", systemImage: "calendar")
                        }
                    )
                    ForEach(viewModel.availableTags) { tag in
                        Button(action: { viewModel.applyTag(tag) }) {
                            Text(tag.text)
                        }
                    }
                    Button(action: createNewTag) {
                        Label("New tag", systemImage: "plus")
                    }
                }
            },
            label: {
                Image(systemName: "plus")
            }
        )
        .buttonStyle(BorderedButtonStyle())
    }
}
