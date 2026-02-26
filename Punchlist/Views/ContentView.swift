import SwiftUI

struct ContentView: View {
    @State private var viewModel = PunchlistViewModel()
    @State private var inputText = ""
    @State private var showDebugLog = false
    @State private var showProjectPicker = false
    @State private var expandedItemID: String?
    @State private var questionSelections: [String: [String: String]] = [:]  // itemID -> (questionID -> value)
    @State private var questionOtherText: [String: [String: String]] = [:]  // itemID -> (questionID -> text)
    @State private var lastInactiveDate: Date?
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            if showProjectPicker {
                projectPicker
            }
            ZStack {
                VStack(spacing: 0) {
                    itemList
                    offlineNotice
                    inputBar
                }
                if showProjectPicker {
                    LinearGradient(
                        stops: [
                            .init(color: Color.punchBackground.opacity(0.95), location: 0),
                            .init(color: Color.punchBackground.opacity(0.6), location: 0.2),
                            .init(color: Color.punchBackground.opacity(0.6), location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(true)
                    .onTapGesture {
                        dismissPicker()
                    }
                }
            }
        }
        .background(Color.punchBackground)
        .onTapGesture { inputFocused = false }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // Only refresh on foreground resume, not initial launch.
                // lastInactiveDate is nil on first launch so this skips the
                // start()/refresh() double-connect race.
                if lastInactiveDate != nil {
                    showProjectPicker = false
                    viewModel.refresh()
                }
            case .inactive, .background:
                lastInactiveDate = Date()
            @unknown default:
                break
            }
        }
    }

    private var projectPicker: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.projects) { project in
                Button {
                    viewModel.switchToProject(slug: project.slug)
                    expandedItemID = nil
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showProjectPicker = false
                    }
                } label: {
                    HStack {
                        Text(project.slug == "user" ? "personal" : "#\(project.slug)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(project.slug == (viewModel.currentProject?.slug ?? "") ? Color.punchText : Color.punchGray)
                            .tracking(0.5)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(.bottom, 8)
    }

    private var header: some View {
        ZStack {
            HStack {
                Text("punchlist")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.punchGray)
                    .tracking(0.5)
                Spacer()
                Text(projectTag ?? "")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.punchGray)
                    .tracking(0.5)
                    .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if showProjectPicker {
                            dismissPicker()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showProjectPicker = true
                            }
                        }
                    }
            }

            if !viewModel.isPersonal,
               !showProjectPicker {
                if viewModel.hasReviewableSession {
                    completionCircle
                } else if let agentState = viewModel.agentState,
                          agentState != .notProvisioned,
                          viewModel.hasUnblockedTickets {
                    agentToggle(isRunning: agentState == .running)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private func agentToggle(isRunning: Bool) -> some View {
        Button {
            viewModel.toggleAgent()
        } label: {
            Capsule()
                .fill(isRunning ? Color.punchBlue : Color.punchGray.opacity(0.3))
                .frame(width: 40, height: 22)
                .overlay(alignment: isRunning ? .trailing : .leading) {
                    Circle()
                        .fill(.white)
                        .frame(width: 18, height: 18)
                        .padding(2)
                        .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRunning)
        }
    }

    private var completionCircle: some View {
        Button {
            viewModel.clearAgentSession()
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.punchGreen)
        }
    }

    private var projectTag: String? {
        guard !viewModel.isPersonal else { return nil }
        guard let project = viewModel.currentProject else { return nil }
        return "#\(project.slug)"
    }

    private func dismissPicker() {
        expandedItemID = nil
        // Clear session state for current project before switching to personal
        if !viewModel.isPersonal {
            viewModel.clearAgentSession()
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showProjectPicker = false
        }
        viewModel.switchToProject(slug: "user")
    }

    private var itemList: some View {
        let reversed = Array(viewModel.items.reversed())
        return ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(reversed.enumerated()), id: \.element.id) { index, item in
                        if !viewModel.isPersonal,
                           index > 0,
                           let prev = reversed[index - 1].priority,
                           let curr = item.priority,
                           prev != curr {
                            Divider()
                                .padding(.vertical, 4)
                        }
                        ItemRow(
                            item: item,
                            isPersonal: viewModel.isPersonal,
                            isExpanded: expandedItemID == item.id,
                            questions: item.planQuestions ?? [],
                            selections: selectionsBinding(for: item.id),
                            otherText: otherTextBinding(for: item.id),
                            onToggle: { viewModel.toggleItem(item) },
                            onBump: { viewModel.bumpItem(item) },
                            onExpand: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    expandedItemID = item.id
                                }
                            },
                            onCollapse: {
                                submitAnswersIfNeeded(for: item.id)
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    expandedItemID = nil
                                }
                                // Scroll to the collapsed item after the animation completes
                                // to force the ScrollView to recalculate its content size
                                Task { @MainActor in
                                    try? await Task.sleep(for: .milliseconds(350))
                                    proxy.scrollTo(item.id, anchor: .bottom)
                                }
                            }
                        )
                        .id(item.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .scrollDismissesKeyboard(.interactively)
            .defaultScrollAnchor(.bottom)
        }
    }

    @ViewBuilder
    private var offlineNotice: some View {
        if viewModel.showOffline {
            Text("offline \u{2014} will sync when reconnected")
                .font(.system(size: 12))
                .foregroundStyle(Color.punchGray)
                .padding(.vertical, 8)
                .onTapGesture { showDebugLog.toggle() }
        }

        if showDebugLog {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(viewModel.debugLog, id: \.self) { entry in
                        Text(entry)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.punchGray)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 150)
            .background(Color.punchBackground)
        }
    }

    // MARK: - Plan question state helpers

    private func selectionsBinding(for itemID: String) -> Binding<[String: String]> {
        Binding(
            get: { questionSelections[itemID] ?? [:] },
            set: { questionSelections[itemID] = $0 }
        )
    }

    private func otherTextBinding(for itemID: String) -> Binding<[String: String]> {
        Binding(
            get: { questionOtherText[itemID] ?? [:] },
            set: { questionOtherText[itemID] = $0 }
        )
    }

    private func submitAnswersIfNeeded(for itemID: String) {
        let sels = questionSelections[itemID] ?? [:]
        guard !sels.isEmpty else { return }

        // Resolve _other selections to their freeform text
        let others = questionOtherText[itemID] ?? [:]
        var answers: [String: String] = [:]
        for (questionID, value) in sels {
            if value == "_other" {
                let text = (others[questionID] ?? "").trimmingCharacters(in: .whitespaces)
                if !text.isEmpty {
                    answers[questionID] = text
                }
            } else {
                answers[questionID] = value
            }
        }

        if !answers.isEmpty {
            viewModel.submitAnswers(for: itemID, answers: answers)
        }

        // Clear local state
        questionSelections.removeValue(forKey: itemID)
        questionOtherText.removeValue(forKey: itemID)
    }

    private var inputBar: some View {
        InputBar(text: $inputText, isFocused: $inputFocused) {
            viewModel.addItem(text: inputText)
            inputText = ""
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
