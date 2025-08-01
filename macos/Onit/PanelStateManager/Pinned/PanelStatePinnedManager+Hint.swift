//
//  PanelStatePinnedManager+Hint.swift
//  Onit
//
//  Created by Kévin Naudin on 12/05/2025.
//

import Foundation
import SwiftUI
import Defaults

extension PanelStatePinnedManager {
      
    func debouncedShowTetherWindow(activeScreen: NSScreen) {
        hideTetherWindow()

        tetherHintDetails.showTetherDebounceTimer = Timer.scheduledTimer(
            withTimeInterval: tetherHintDetails.showTetherDebounceDelay,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.showTetherWindow(activeScreen: activeScreen)
            }
        }
    }

    private func showTetherWindow(activeScreen: NSScreen) {
        let tetherView = ExternalTetheredButton(
            onClick: { [weak self] in
                self?.tetherHintClicked(screen: activeScreen)
            },
            onDrag: { [weak self] translation in
              if ((Defaults[.overlayMode]) == false ) {
                self?.tetheredWindowMoved(screen: activeScreen, y: translation)
              }
            }
        ).environment(\.windowState, state)

        let buttonView = OnitHostingView(rootView: tetherView)
        tetherHintDetails.tetherWindow.contentView = buttonView
        tetherButtonPanelState = state

        updateTetherWindowPosition(for: activeScreen, lastYComputed: tetherHintDetails.lastYComputed)
        tetherHintDetails.tetherWindow.orderFrontRegardless()
    }
    
    private func tetherHintClicked(screen: NSScreen) {
        state.trackedScreen = screen
        launchPanel(for: state)
    }
    
    private func updateTetherWindowPosition(for screen: NSScreen, lastYComputed: CGFloat? = nil) {
        let activeScreenFrame = screen.visibleFrame
        let positionX = Defaults[.overlayMode] ? activeScreenFrame.maxX - ExternalTetheredButton.containerWidth - 20 : activeScreenFrame.maxX - ExternalTetheredButton.containerWidth
      
        var positionY: CGFloat
        if !Defaults[.overlayMode] {
          if let relativePosition = hintYRelativePosition {
            positionY = activeScreenFrame.minY + (relativePosition * activeScreenFrame.height) - (ExternalTetheredButton.containerHeight / 2)
            positionY = max(activeScreenFrame.minY, min(positionY, activeScreenFrame.maxY - ExternalTetheredButton.containerHeight))
          } else if lastYComputed == nil {
            positionY = activeScreenFrame.minY + (activeScreenFrame.height / 2) - (ExternalTetheredButton.containerHeight / 2)
          } else {
            positionY = computeHintYPosition(for: activeScreenFrame, offset: lastYComputed)
          }
        } else {
          positionY = activeScreenFrame.minY - 5
        }
        
        let frame = NSRect(
            x: positionX,
            y: positionY,
            width: ExternalTetheredButton.containerWidth,
            height: ExternalTetheredButton.containerHeight
        )
        tetherHintDetails.tetherWindow.setFrame(frame, display: false)
    }
    
    private func computeHintYPosition(for screenVisibleFrame: CGRect, offset: CGFloat?) -> CGFloat {
        let maxY = screenVisibleFrame.maxY - ExternalTetheredButton.containerHeight
        let minY = screenVisibleFrame.minY + 10

        var lastYComputed = tetherHintDetails.lastYComputed ?? screenVisibleFrame.minY + (screenVisibleFrame.height / 2) - (ExternalTetheredButton.containerHeight / 2)

        if let offset = offset {
            lastYComputed -= offset
        }

        let finalOffset: CGFloat

        if lastYComputed > maxY {
            finalOffset = maxY
        } else if lastYComputed < minY {
            finalOffset = minY
        } else {
            finalOffset = lastYComputed
        }

        return finalOffset
    }

    private func tetheredWindowMoved(screen: NSScreen, y: CGFloat) {
        let screenFrame = screen.visibleFrame
        let lastYComputed = computeHintYPosition(for: screenFrame, offset: y)
        
        tetherHintDetails.lastYComputed = lastYComputed
        
        let relativeY = (lastYComputed + (ExternalTetheredButton.containerHeight / 2) - screenFrame.minY) / screenFrame.height
        
        hintYRelativePosition = max(0.0, min(1.0, relativeY))
        tetherButtonPanelState?.tetheredButtonYRelativePosition = hintYRelativePosition

        let frame = NSRect(
            x: tetherHintDetails.tetherWindow.frame.origin.x,
            y: lastYComputed,
            width: ExternalTetheredButton.containerWidth,
            height: ExternalTetheredButton.containerHeight
        )
        
        tetherHintDetails.tetherWindow.setFrame(frame, display: true)
    }
}
