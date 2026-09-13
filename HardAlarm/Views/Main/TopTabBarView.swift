import SwiftUI

struct TopTabBarView: View {
    @Binding var selectedTab: ActiveTab
    @ScaledMetric(relativeTo: .subheadline) private var fontSize: CGFloat = 15
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        AdaptiveTabBarLayout(horizontalSpacing: 10, verticalSpacing: 10) {
            ForEach(ActiveTab.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button(action: {
                    Haptics.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.system(size: max(14, fontSize), weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundColor(isSelected ? Theme.primaryOrange : Theme.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        
                        // Underline with pip dot indicator
                        ZStack {
                            if isSelected {
                                Rectangle()
                                    .fill(Theme.primaryOrange)
                                    .frame(height: 2)
                                    .overlay(
                                        Circle()
                                            .fill(Theme.primaryOrange)
                                            .frame(width: 5, height: 5)
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(height: 5)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text(tab.rawValue))
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Adaptive Tab Bar Layout
/// An adaptive flow layout that displays tab buttons in a single row with equal distribution
/// when space permits, and wraps gracefully into multiple centered rows when larger fonts
/// or narrower screens prevent a single-row layout.
struct AdaptiveTabBarLayout: Layout {
    var horizontalSpacing: CGFloat = 10
    var verticalSpacing: CGFloat = 10
    
    struct Row {
        var items: [(subview: LayoutSubview, size: CGSize)]
        var totalWidth: CGFloat
        var maxHeight: CGFloat
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentItems: [(subview: LayoutSubview, size: CGSize)] = []
        var currentWidth: CGFloat = 0
        var currentMaxHeight: CGFloat = 0
        
        for subview in subviews {
            let itemSize = subview.sizeThatFits(ProposedViewSize(width: nil, height: nil))
            let neededWidth = currentItems.isEmpty ? itemSize.width : currentWidth + horizontalSpacing + itemSize.width
            
            if neededWidth > maxWidth && !currentItems.isEmpty {
                // Wrap to next row
                rows.append(Row(items: currentItems, totalWidth: currentWidth, maxHeight: currentMaxHeight))
                currentItems = [(subview, itemSize)]
                currentWidth = itemSize.width
                currentMaxHeight = itemSize.height
            } else {
                currentItems.append((subview, itemSize))
                currentWidth = neededWidth
                currentMaxHeight = max(currentMaxHeight, itemSize.height)
            }
        }
        
        if !currentItems.isEmpty {
            rows.append(Row(items: currentItems, totalWidth: currentWidth, maxHeight: currentMaxHeight))
        }
        
        return rows
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let totalHeight = rows.map { $0.maxHeight }.reduce(0, +) + CGFloat(max(0, rows.count - 1)) * verticalSpacing
        let maxRowWidth = rows.map { $0.totalWidth }.max() ?? 0
        let targetWidth = proposal.width ?? maxRowWidth
        return CGSize(width: targetWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        
        // Single row scenario: if all items fit comfortably, distribute equally across full width
        if rows.count == 1, let singleRow = rows.first, !subviews.isEmpty {
            let equalWidth = bounds.width / CGFloat(subviews.count)
            let maxItemWidth = singleRow.items.map { $0.size.width }.max() ?? 0
            
            // If equal distribution provides enough room for every tab without cramping
            if equalWidth >= maxItemWidth {
                for (index, item) in singleRow.items.enumerated() {
                    let x = bounds.minX + CGFloat(index) * equalWidth
                    item.subview.place(
                        at: CGPoint(x: x, y: bounds.minY),
                        proposal: ProposedViewSize(width: equalWidth, height: singleRow.maxHeight)
                    )
                }
                return
            }
        }
        
        // Multi-row wrapping scenario: center each row horizontally
        var currentY = bounds.minY
        for row in rows {
            var xOffset = bounds.minX + max(0, (bounds.width - row.totalWidth) / 2)
            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: xOffset, y: currentY),
                    proposal: ProposedViewSize(item.size)
                )
                xOffset += item.size.width + horizontalSpacing
            }
            currentY += row.maxHeight + verticalSpacing
        }
    }
}
