//
//  ToolbarLeft.swift
//  Onit
//
//  Created by Kévin Naudin on 25/03/2025.
//

import SwiftUI
import Defaults

struct ToolbarLeft: View {
    @Environment(\.windowState) private var state
    @Default(.overlayMode) var overlayMode
  
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            esc
            
            HStack(alignment: .center, spacing: 0) {
                newChatButton
                systemPromptsButton
            }
        }
    }
    
  private var esc: some View {
    IconButton(
        icon: .redCircle,
        iconSize: 13,
        inactiveColor: .closeRed,
        hoverColor: .closeRed,
        tooltipShortcut: .keyboardShortcuts(.escape)
    ) {
        AnalyticsManager.Toolbar.escapePressed()
        PanelStateCoordinator.shared.closePanel()
    }
}
    
    private var newChatButton: some View {
        IconButton(
            icon: .circlePlus,
            iconSize: 17,
            tooltipPrompt: "New Chat",
            tooltipShortcut: .keyboardShortcuts(.newChat)
        ) {
            AnalyticsManager.Toolbar.newChatPressed()
            state?.newChat()
        }
    }
    
    private var systemPromptsButton: some View {
        IconButton(
            icon: .smallChevDown,
            tooltipPrompt: "Start new Chat with system prompt"
        ) {
            AnalyticsManager.Toolbar.systemPromptPressed()
            state?.newChat()
            state?.systemPromptState.shouldShowSelection = true
            state?.systemPromptState.shouldShowSystemPrompt = true
        }
        .onHover(perform: { isHovered in
            if isHovered && state?.currentChat?.systemPrompt == nil && state?.systemPromptState.shouldShowSystemPrompt != true &&
          !overlayMode {
                state?.systemPromptState.shouldShowSystemPrompt = true
            }
        })
    }
}

// MARK: - Preview

#Preview {
    ToolbarLeft()
}
