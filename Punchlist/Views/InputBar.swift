import SwiftUI

struct InputBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSubmit: () -> Void

    var body: some View {
        TextField("Add item...", text: $text)
            .focused(isFocused)
            .textFieldStyle(.plain)
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.08), radius: 1.5, y: 1)
            .submitLabel(.done)
            .onSubmit {
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onSubmit()
                isFocused.wrappedValue = true
            }
    }
}
