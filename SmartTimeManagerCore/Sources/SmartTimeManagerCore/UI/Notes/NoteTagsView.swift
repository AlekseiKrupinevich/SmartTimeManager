import SwiftUI

struct NoteTagsView<DI: DIProtocol>: View {
    @Binding var note: NoteModel
    @EnvironmentObject private var interactor: DI.NotesInteractorType
    @StateObject private var viewModel: NoteTagsViewModel<DI>
    @State private var isCreateTagSheetVisible = false
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    
    init(note: Binding<NoteModel>) {
        _note = note
        _viewModel = StateObject(wrappedValue: NoteTagsViewModel(note: note))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .font(.headline)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(viewModel.appliedTags) { tag in
                        NoteTagView(
                            tag: tag,
                            action: {
                                viewModel.removeTag(id: tag.id)
                            }
                        )
                    }
                    AvailableTagsMenu<DI>(
                        createNewTag: {
                            isCreateTagSheetVisible = true
                        },
                        createCustomDateTag: { }
                    )
                    .environmentObject(viewModel)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear() {
            viewModel.interactor = interactor
            viewModel.update()
        }
        .sheet(
            isPresented: $isCreateTagSheetVisible,
            content: {
                CreateTagSheet(
                    cancel: { isCreateTagSheetVisible = false },
                    create: createTag
                )
            }
        )
        .alert(alertTitle, isPresented: $isAlertPresented, actions: {})
    }
}

extension NoteTagsView {
    func createTag(text: String, color: Color) {
        guard viewModel.validateNewTag(text: text) else {
            alertTitle = "A tag with this text already exists"
            isAlertPresented = true
            return
        }
        isCreateTagSheetVisible = false
        viewModel.applyTag(.text((text, color)))
    }
}
