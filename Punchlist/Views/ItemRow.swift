import SwiftUI

struct ItemRow: View {
    let item: Item
    let isPersonal: Bool
    let isExpanded: Bool
    let onToggle: () -> Void
    let onBump: () -> Void
    let onExpand: () -> Void
    let onCollapse: () -> Void

    @State private var pulseActive = false
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var holdStartTime: Date?
    @State private var holdDelayTask: Task<Void, Never>?

    private var isInProgress: Bool {
        item.status == "in_progress"
    }

    private var isBlocked: Bool {
        item.status == "blocked"
    }

    private var hasUnresolvedDep: Bool {
        item.hasUnresolvedDep == true
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
        if hasUnresolvedDep { return .punchOrange }
        return .clear
    }

    private var hasDescription: Bool {
        guard let desc = item.description else { return false }
        return !desc.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tappable region: header + expanded text (ticket ID, description)
            VStack(alignment: .leading, spacing: 0) {
                headerRow
                if isExpanded {
                    expandedText
                }
            }
            .contentShape(Rectangle())
            .overlay { tapOverlay }

            // Interactive elements sit outside the tap overlay so their gestures aren't blocked
            if isExpanded && !item.done {
                if isBlocked {
                    PlanQuestionsView(questions: Self.hardcodedQuestions)
                        .padding(.top, 12)
                }
                holdToCloseBar
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(accentColor.opacity(hasActiveStatus ? 0.3 : 0), lineWidth: 1)
        )
        .shadow(color: hasActiveStatus ? accentColor.opacity(hasPulse ? (pulseActive ? 0.18 : 0.06) : 0.12) : .black.opacity(0.08),
                radius: hasActiveStatus ? (hasPulse ? (pulseActive ? 8 : 4) : 6) : 1.5, y: hasActiveStatus ? 0 : 1)
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
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 14) {
                circle
                text
            }

            Spacer(minLength: 8)

            if !item.done {
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 0.87, green: 0.87, blue: 0.87)) // #DDDDDD
                    .padding(.trailing, 8)
            }
        }
    }

    /// The 80/20 tap overlay: left for primary action, right for bump.
    /// Covers the tappable region of the card (header + expanded text, but not the hold-to-close bar).
    private var tapOverlay: some View {
        GeometryReader { geo in
            if item.done {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { onToggle() }
            } else {
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { isPersonal ? onToggle() : onExpand() }

                    Color.clear
                        .frame(width: geo.size.width * 0.2)
                        .contentShape(Rectangle())
                        .onTapGesture { onBump() }
                }
            }
        }
    }

    private var expandedText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.id)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.punchGray.opacity(0.6))
                .padding(.top, 8)
                .padding(.leading, 44)

            if let desc = item.description, !desc.isEmpty {
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.punchGray)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 44)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var holdToCloseBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.punchGray.opacity(0.08))

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.punchGreen.opacity(0.35))
                    .frame(width: geo.size.width * holdProgress)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isHolding else { return }
                        isHolding = true
                        holdStartTime = Date()
                        // Wait 0.2s grace period, then start the fill animation
                        holdDelayTask = Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(200))
                            guard !Task.isCancelled, isHolding else { return }
                            withAnimation(.linear(duration: 1.3)) {
                                holdProgress = 1.0
                            }
                            // After 1.3s animation completes, close the item
                            try? await Task.sleep(for: .milliseconds(1300))
                            guard !Task.isCancelled, isHolding else { return }
                            isHolding = false
                            holdProgress = 0
                            holdStartTime = nil
                            onToggle()
                        }
                    }
                    .onEnded { _ in
                        guard isHolding else { return }
                        let elapsed = Date().timeIntervalSince(holdStartTime ?? Date())
                        holdDelayTask?.cancel()
                        holdDelayTask = nil
                        isHolding = false
                        holdStartTime = nil

                        if elapsed < 0.2 {
                            // Quick tap — collapse the card
                            holdProgress = 0
                            onCollapse()
                        } else {
                            // Released mid-hold — cancel fill
                            withAnimation(.easeOut(duration: 0.2)) {
                                holdProgress = 0
                            }
                        }
                    }
            )
        }
        .frame(height: 28)
    }

    private var circleColor: Color {
        if item.done { return .punchGreen }
        if isBlocked { return .punchPink }
        if isInProgress { return .punchBlue }
        if hasUnresolvedDep { return .punchOrange }
        return .punchGray
    }

    private var circle: some View {
        ZStack {
            if hasActiveStatus {
                Circle()
                    .fill(accentColor.opacity(hasPulse ? (pulseActive ? 0.25 : 0.1) : 0.18))
            } else if hasUnresolvedDep {
                Circle()
                    .fill(accentColor.opacity(0.18))
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
        .frame(width: 30, height: 30)
    }

    // MARK: - Hardcoded plan questions (placeholder until server-driven)

    static let hardcodedQuestions: [PlanQuestion] = [
        PlanQuestion(
            id: "q1",
            question: "Should we keep backwards compatibility with pipeline.yml?",
            context: "INVARIANTS.md says 'avoid backwards-compatibility hacks', but this is infrastructure work that could disrupt users mid-development.",
            options: [
                PlanOption(label: "Deprecation path (Recommended)", value: "deprecate",
                           description: "FindPipelineConfig tries config.yaml first, falls back to pipeline.yml with a stderr warning. Remove fallback in a future ticket."),
                PlanOption(label: "Hard break", value: "hard_break",
                           description: "Only look for config.yaml. Old pipeline.yml files are ignored immediately."),
                PlanOption(label: "Silent fallback", value: "silent_fallback",
                           description: "Try config.yaml first, fall back to pipeline.yml without warning. No migration pressure."),
            ]
        ),
        PlanQuestion(
            id: "q2",
            question: "What happens to the standalone .ko/prefix file for existing projects?",
            context: "Old projects have .ko/prefix. New projects will write prefix into config.yaml.",
            options: [
                PlanOption(label: "Read fallback, write new only (Recommended)", value: "fallback_read",
                           description: "ReadPrefix checks config.yaml first, falls back to .ko/prefix. WritePrefix only writes to config.yaml. Natural migration on next write."),
                PlanOption(label: "Dual write", value: "dual_write",
                           description: "Write prefix to both config.yaml and .ko/prefix for full backwards compat."),
                PlanOption(label: "Hard break", value: "hard_break_prefix",
                           description: "Only read/write config.yaml. Old .ko/prefix files are ignored immediately."),
            ]
        ),
        PlanQuestion(
            id: "q3",
            question: "Should prefix be writable after init, or set-once?",
            context: "Currently WritePrefix exists and is called from detectPrefix. But prefix changes are rare and potentially dangerous (breaks existing ticket IDs).",
            options: [
                PlanOption(label: "Keep writable (Recommended)", value: "writable",
                           description: "Maintain existing behavior. Read config, update prefix field, write back. Don't optimize for a rare operation."),
                PlanOption(label: "Set-once, warn on change", value: "set_once_warn",
                           description: "Allow writes but emit a warning when changing an existing prefix. Makes the danger visible."),
                PlanOption(label: "Set-once, error on change", value: "set_once_error",
                           description: "Refuse to change prefix after init. Require a --force flag or manual config edit."),
            ]
        ),
    ]

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
    static let punchPink = Color(red: 1.0, green: 0.38, blue: 0.533)       // #FF6188
    static let punchOrange = Color(red: 0.957, green: 0.647, blue: 0.486)  // #F3A57C
}
