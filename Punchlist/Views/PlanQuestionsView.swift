import SwiftUI

struct PlanQuestionsView: View {
    let questions: [PlanQuestion]
    @State private var selections: [String: String] = [:]    // questionID -> optionValue (or "_other")
    @State private var otherText: [String: String] = [:]     // questionID -> freeform text
    @FocusState private var focusedQuestion: String?

    /// Whether every question has been answered (option selected, or Other with text).
    var allAnswered: Bool {
        questions.allSatisfy { q in
            guard let sel = selections[q.id] else { return false }
            if sel == "_other" {
                return !(otherText[q.id] ?? "").trimmingCharacters(in: .whitespaces).isEmpty
            }
            return true
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thin divider with pink tint
            Rectangle()
                .fill(Color.punchPink.opacity(0.2))
                .frame(height: 1)
                .padding(.bottom, 14)

            ForEach(questions) { question in
                questionBlock(question)
            }
        }
    }

    private func questionBlock(_ question: PlanQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.question)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.punchText)
                .fixedSize(horizontal: false, vertical: true)

            if let context = question.context, !context.isEmpty {
                Text(context)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.punchGray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            optionPills(for: question)
                .padding(.top, 2)

            // Show selected option's description
            if let selected = selections[question.id], selected != "_other",
               let option = question.options.first(where: { $0.value == selected }) {
                Text(option.description)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.punchGray.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }

            // Show freeform input when "Other" is selected
            if selections[question.id] == "_other" {
                otherInput(for: question)
                    .padding(.top, 2)
            }
        }
        .padding(.bottom, 16)
    }

    private func optionPills(for question: PlanQuestion) -> some View {
        FlowLayout(spacing: 6) {
            ForEach(question.options) { option in
                let isSelected = selections[question.id] == option.value
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if isSelected {
                            selections.removeValue(forKey: question.id)
                        } else {
                            selections[question.id] = option.value
                        }
                    }
                } label: {
                    Text(option.label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(isSelected ? .white : Color.punchPink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.punchPink : Color.punchPink.opacity(0.08))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.punchPink.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            // "Other" pill
            let isOther = selections[question.id] == "_other"
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isOther {
                        selections.removeValue(forKey: question.id)
                    } else {
                        selections[question.id] = "_other"
                    }
                }
            } label: {
                Text("Other")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isOther ? .white : Color.punchGray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(isOther ? Color.punchGray : Color.punchGray.opacity(0.08))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.punchGray.opacity(isOther ? 0 : 0.25), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func otherInput(for question: PlanQuestion) -> some View {
        let binding = Binding<String>(
            get: { otherText[question.id] ?? "" },
            set: { newValue in
                if newValue.contains("\n") {
                    otherText[question.id] = newValue.replacingOccurrences(of: "\n", with: "")
                    focusedQuestion = nil
                } else {
                    otherText[question.id] = newValue
                }
            }
        )
        return TextField("Your answer...", text: binding, axis: .vertical)
            .font(.system(size: 12))
            .foregroundStyle(Color.punchText)
            .lineLimit(2...4)
            .submitLabel(.done)
            .focused($focusedQuestion, equals: question.id)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.punchGray.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.punchGray.opacity(0.12), lineWidth: 1)
            )
    }
}

/// Simple flow layout that wraps children to the next line when they exceed available width.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalWidth = max(totalWidth, x - spacing)
            totalHeight = y + rowHeight
        }

        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}
