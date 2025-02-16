import SwiftUI

struct NoteTagView: View {
    let tag: NoteTagViewModel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(tag.text)
                Image(systemName: "xmark")
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 6)
            .foregroundStyle(.white)
            .background(tag.color)
            .cornerRadius(6)
        }
    }
}
