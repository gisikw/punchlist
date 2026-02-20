import SwiftUI

struct ItemRow: View {
    let item: Item
    let isPersonal: Bool
    let onToggle: () -> Void
    let onBump: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 14) {
                circle
                text
            }

            Spacer(minLength: 0)

            if !item.done {
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 0.87, green: 0.87, blue: 0.87)) // #DDDDDD
                    .padding(.trailing, 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.08), radius: 1.5, y: 1)
        .contentShape(Rectangle())
        .overlay {
            if isPersonal {
                // Personal: left 80% toggles, right 20% bumps
                if !item.done {
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { onToggle() }

                            Color.clear
                                .frame(width: geo.size.width * 0.2)
                                .contentShape(Rectangle())
                                .onTapGesture { onBump() }
                        }
                    }
                } else {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { onToggle() }
                }
            } else {
                // Project: tap bumps undone items, tap toggles done items
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if item.done {
                            onToggle()
                        } else {
                            onBump()
                        }
                    }
            }
        }
    }

    private var circle: some View {
        ZStack {
            Circle()
                .strokeBorder(item.done ? Color.punchGreen : Color.punchGray, lineWidth: 2)
                .frame(width: 22, height: 22)

            if item.done {
                Circle()
                    .fill(Color.punchGreen)
                    .frame(width: 22, height: 22)

                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var text: some View {
        Text(item.text)
            .font(.body)
            .foregroundStyle(item.done ? Color.punchGray : Color.punchText)
            .strikethrough(item.done, color: Color.punchGray)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
}

extension Color {
    static let punchBackground = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    static let punchText = Color(red: 0.176, green: 0.165, blue: 0.18)     // #2D2A2E
    static let punchGray = Color(red: 0.576, green: 0.573, blue: 0.576)    // #939293
    static let punchGreen = Color(red: 0.663, green: 0.863, blue: 0.463)   // #A9DC76
    static let punchBlue = Color(red: 0.471, green: 0.863, blue: 0.91)     // #78DCE8
}
