import SwiftUI

struct AvailableTagsMenu<DI: DIProtocol>: View {
    @EnvironmentObject var viewModel: NoteTagsViewModel<DI>
    let createNewTag: () -> Void
    let createCustomDateTag: () -> Void
    let displayError: (String) -> Void
    
    var body: some View {
        Menu(
            content: {
                HStack {
                    Menu(
                        content: {
                            ForEach(viewModel.availableDateTags) { dateTag in
                                Button(
                                    action: { applyDateTag(dateTag) },
                                    label: { Text(dateTag.title) }
                                )
                            }
                        },
                        label: {
                            Label("Date", systemImage: "calendar")
                        }
                    )
                    ForEach(viewModel.availableTags) { tag in
                        Button(action: { viewModel.applyTag(tag.tag) }) {
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

extension AvailableTagsMenu {
    func applyDateTag(_ dateTag: NoteTagsViewModel<DI>.DateTag) {
        switch dateTag.type {
        case .customDate:
            createCustomDateTag()
        default:
            if viewModel.isApplied(dateTag) {
                displayError("The tag is already applied")
            } else {
                viewModel.applyDateTag(dateTag)
            }
        }
    }
}
