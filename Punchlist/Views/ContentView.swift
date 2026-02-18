import SwiftUI

struct ContentView: View {
    @State private var viewModel = PunchlistViewModel()
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            itemList
            offlineNotice
            inputBar
        }
        .background(Color.punchBackground)
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
                    ForEach(viewModel.items) { item in
                        ItemRow(
                            item: item,
                            onToggle: { viewModel.toggleItem(item) },
                            onBump: { viewModel.bumpItem(item) }
                        )
                        .id(item.id)
                    }
                    .onDelete { offsets in
                        let toDelete = offsets.map { viewModel.items[$0] }
                        for item in toDelete {
                            viewModel.deleteItem(item)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
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
        }
    }

    private var inputBar: some View {
        InputBar(text: $inputText) {
            viewModel.addItem(text: inputText)
            inputText = ""
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
