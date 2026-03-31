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
                    placeholder: "Text".localized
                )
                .focused($focused)
                ColorPicker("Color".localized, selection: $color)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("New Tag".localized)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel".localized)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { create(text, color) }) {
                        Text("Create".localized)
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
