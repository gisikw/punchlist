import SwiftUI

struct ContentView: View {
    @State private var viewModel = PunchlistViewModel()
    @State private var inputText = ""
    @State private var showDebugLog = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            itemList
            offlineNotice
            inputBar
        }
        .background(Color.punchBackground)
        .onTapGesture { inputFocused = false }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    private var header: some View {
        HStack {
            Text("punchlist")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.punchGray)
                .tracking(0.5)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
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
