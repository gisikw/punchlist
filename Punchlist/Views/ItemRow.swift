import SwiftUI

struct ItemRow: View {
    let item: Item
    let isPersonal: Bool
    let onToggle: () -> Void
    let onBump: () -> Void

    @State private var pulseActive = false

    private var isInProgress: Bool {
        item.status == "in_progress"
    }

    private var isBlocked: Bool {
        item.status == "blocked"
    }

    private var hasPulse: Bool {
        isInProgress
    }

    private var hasActiveStatus: Bool {
        isInProgress || isBlocked
    }

    private var accentColor: Color {
        if isBlocked { return .punchPink }
        if isInProgress { return .punchBlue }
        return .clear
    }

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
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(accentColor.opacity(hasActiveStatus ? 0.3 : 0), lineWidth: 1)
        )
        .shadow(color: hasActiveStatus ? accentColor.opacity(hasPulse ? (pulseActive ? 0.18 : 0.06) : 0.12) : .black.opacity(0.08),
                radius: hasActiveStatus ? (hasPulse ? (pulseActive ? 8 : 4) : 6) : 1.5, y: hasActiveStatus ? 0 : 1)
        .contentShape(Rectangle())
        .onAppear {
            if hasPulse {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseActive = true
                }
            }
        }
        .onChange(of: hasPulse) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseActive = true
                }
            } else {
                pulseActive = false
            }
        }
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

    private var circleColor: Color {
        if item.done { return .punchGreen }
        if isBlocked { return .punchPink }
        if isInProgress { return .punchBlue }
        return .punchGray
    }

    private var circle: some View {
        ZStack {
            if hasActiveStatus {
                Circle()
                    .fill(accentColor.opacity(hasPulse ? (pulseActive ? 0.25 : 0.1) : 0.18))
                    .frame(width: 30, height: 30)
            }

            Circle()
                .strokeBorder(circleColor, lineWidth: 2)
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
    static let punchPink = Color(red: 1.0, green: 0.38, blue: 0.533)      // #FF6188
}
