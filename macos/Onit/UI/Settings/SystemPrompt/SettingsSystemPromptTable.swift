//
//  SettingsSystemPromptTable.swift
//  Onit
//
//  Created by Kévin Naudin on 07/02/2025.
//

import KeyboardShortcuts
import SwiftData
import SwiftUI

struct SettingsSystemPromptTable: View {
    @Query var prompts: [SystemPrompt]
    @Binding var filter: String
    @Binding var selectedPrompt: SystemPrompt?
    @Binding var refreshUI: Bool
    
    @State private var selected = Set<SystemPrompt.ID>()
    
    private var filteredPrompts: [SystemPrompt] {
        let clearFilter = filter
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        return if clearFilter.isEmpty {
            prompts
        } else {
            prompts.filter {
                $0.name.lowercased().contains(clearFilter) ||
                $0.prompt.lowercased().contains(clearFilter) ||
                $0.tags.joined(separator: ",").lowercased().contains(clearFilter)
            }
        }
    }
    
    var body: some View {
        Table(filteredPrompts, selection: $selected) {
            TableColumn("Name", value: \.name)
            TableColumn("Hotkey") { prompt in
                if let shortcut = KeyboardShortcuts.Name(prompt.id).shortcut?.native {
                    KeyboardShortcutView(shortcut: shortcut, characterWidth: 12, spacing: 3)
                        .font(.system(size: 13, weight: .light))
                } else {
                    Text("record").foregroundColor(.gray)
                }
            }
            TableColumn("Applications") { prompt in
                switch prompt.applications.count {
                case 0:
                    Text("Add default").foregroundColor(.gray)
                case 1:
                    Text(prompt.applications.first?.deletingPathExtension().lastPathComponent ?? "")
                default:
                    Text("\(prompt.applications.count)")
                }
            }
            TableColumn("Tags") { prompt in
                Text("\(prompt.tags.count)")
            }
        }
        .id(refreshUI)
        .onChange(of: selected) { _, new in
            guard let promptId = new.first else {
                selectedPrompt = nil
                return
            }
            selectionChange(promptId: promptId)
        }
    }
    
    private func selectionChange(promptId: String) {
        guard let selectedPrompt = prompts.first(where: { $0.id == promptId }) else { return }
        
        self.selectedPrompt = selectedPrompt
    }
}

#Preview {
    SettingsSystemPromptTable(filter: .constant(""),
                     selectedPrompt: .constant(nil),
                     refreshUI: .constant(false))
}
