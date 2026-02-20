import SwiftUI

struct ContentView: View {
    @State private var viewModel = PunchlistViewModel()
    @State private var inputText = ""
    @State private var showDebugLog = false
    @State private var showProjectPicker = false
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
            if newPhase == .active {
                viewModel.start()
                showProjectPicker = false
            }
        }
    }

    private var projectPicker: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.projects) { project in
                Button {
                    viewModel.switchToProject(slug: project.isDefault ? "personal" : project.slug)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showProjectPicker = false
                    }
                } label: {
                    HStack {
                        Text(project.isDefault ? "personal" : "#\(project.slug)")
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
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private var projectTag: String? {
        guard let project = viewModel.currentProject, !project.isDefault else { return nil }
        return "#\(project.slug)"
    }

    private func dismissPicker() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showProjectPicker = false
        }
        viewModel.switchToProject(slug: "personal")
    }

    private var itemList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.items.reversed()) { item in
                        ItemRow(
                            item: item,
                            onToggle: { viewModel.toggleItem(item) },
                            onBump: { viewModel.bumpItem(item) }
                        )
                        .id(item.id)
                    }
                    .onDelete { offsets in
                        let reversed = viewModel.items.reversed()
                        let toDelete = offsets.map { Array(reversed)[$0] }
                        for item in toDelete {
                            viewModel.deleteItem(item)
                        }
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
        if !viewModel.isConnected {
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

    private var inputBar: some View {
        InputBar(text: $inputText, isFocused: $inputFocused) {
            viewModel.addItem(text: inputText)
            inputText = ""
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
