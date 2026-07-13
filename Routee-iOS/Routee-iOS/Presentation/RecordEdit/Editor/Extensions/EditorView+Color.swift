//
//  EditorView+Color.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/14/26.
//

import UIKit

extension EditorView {
    func setColorAction() {
        recordEditTabBar.onColorSelected = { [weak self] color in
            self?.updateEditorColor(color)
        }
    }

    func updateEditorColor(_ color: UIColor) {
        state.selectedColor = color
        dataInfo.updateColor(color)
        routeTimelineDrawingView.updateColor(color)
        routeSticker.updateColor(color)
    }
}
