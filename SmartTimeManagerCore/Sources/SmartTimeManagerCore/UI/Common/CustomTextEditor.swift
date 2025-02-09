import SwiftUI

struct CustomTextEditor: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .overlay(alignment: .topLeading) {
                    Text(placeholder)
                        .allowsHitTesting(false)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .foregroundColor(text.isEmpty ? .secondary : .clear)
                }
            // It fixes TextEditor default height
            Text(text.isEmpty ? placeholder : text)
                .padding(EdgeInsets(top: 8, leading: 5, bottom: 10, trailing: 5))
                .foregroundColor(.clear)
                .allowsHitTesting(false)
        }
    }
}
