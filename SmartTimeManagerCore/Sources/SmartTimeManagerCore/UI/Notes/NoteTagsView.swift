import SwiftUI

struct NoteTagsView<DI: DIProtocol>: View {
    @Binding var note: NoteModel
    @EnvironmentObject private var interactor: DI.NotesInteractorType
    @StateObject private var viewModel: NoteTagsViewModel<DI>
    @State private var isCreateTagSheetVisible = false
    @State private var isCreateDateTagSheetVisible = false
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
                        createCustomDateTag: {
                            isCreateDateTagSheetVisible = true
                        },
                        displayError: { error in
                            alertTitle = error
                            isAlertPresented = true
                        }
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
        .alert(
            alertTitle,
            isPresented: $isAlertPresented,
            actions: {}
        )
        .sheet(
            isPresented: $isCreateTagSheetVisible,
            content: {
                CreateTagSheet(
                    cancel: { isCreateTagSheetVisible = false },
                    create: createTag
                )
            }
        )
        .sheet(
            isPresented: $isCreateDateTagSheetVisible,
            content: {
                CreateDateTagSheet(
                    cancel: { isCreateDateTagSheetVisible = false },
                    create: createDateTag
                )
            }
        )
    }
}

extension NoteTagsView {
    func createTag(text: String, color: Color) {
        do {
            try viewModel.validateNewTag(text: text)
            isCreateTagSheetVisible = false
            viewModel.applyTag(.text((text, color)))
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
    
    func createDateTag(date: Date, template: String) {
        do {
            try viewModel.validateNewTag(date: date, template: template)
            isCreateDateTagSheetVisible = false
            viewModel.applyTag(.date((date, template)))
        } catch {
            alertTitle = "\(error)"
            isAlertPresented = true
        }
    }
}
