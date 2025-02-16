import SwiftUI

struct CreateTagSheet: View {
    let cancel: () -> Void
    let create: (_ text: String, _ color: Color) -> Void
    @State private var text = ""
    @State private var color = Color.black
    @FocusState private var focused
    
    var body: some View {
        NavigationView {
            List {
                CustomTextEditor(
                    text: $text,
                    placeholder: "Text"
                )
                .focused($focused)
                ColorPicker("Color", selection: $color)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("New Tag")
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { create(text, color) }) {
                        Text("Create")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            focused = true
        }
    }
}
