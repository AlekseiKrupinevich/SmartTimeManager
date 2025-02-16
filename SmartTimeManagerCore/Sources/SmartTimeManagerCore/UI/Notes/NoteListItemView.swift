import SwiftUI

struct NoteListItemView<DI: DIProtocol>: View {
    let itemViewModel: NoteListItemViewModel
    @EnvironmentObject private var viewModel: NotesViewModel<DI>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ScrollView(.horizontal) {
                HStack(spacing: 5) {
                    ForEach(itemViewModel.tags) { tag in
                        Text(tag.text)
                            .font(.callout)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .foregroundStyle(.white)
                            .background(tag.color)
                            .cornerRadius(6)
                    }
                }
            }
            .scrollIndicators(.hidden)
            Text(itemViewModel.text)
        }
    }
}
