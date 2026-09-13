import SwiftUI

struct TopTabBarView: View {
    @Binding var selectedTab: ActiveTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ActiveTab.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button(action: {
                    Haptics.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundColor(isSelected ? Theme.primaryOrange : Theme.textMuted)
                        
                        // Underline with pip dot indicator
                        ZStack {
                            if isSelected {
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Theme.primaryOrange)
                                        .frame(height: 2)
                                }
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
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
