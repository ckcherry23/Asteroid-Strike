//
//  LevelDesignController+Palette.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 22/2/23.
//

import UIKit

extension LevelDesignController {
    @IBAction func onTapPaletteButton(_ sender: PaletteButton) {
        clearAllSelections()
        sender.isSelected = true
        selectedPaletteButton = sender
    }

    @IBAction func onSizeSliderValueChanged(_ sender: UISlider) {
        guard let pegView = selectedCanvasObject as? PegView else {
            return
        }
        let isResizeValid = levelDesigner.resizePegOnGameboard(pegLocation: pegView.location,
                                                               newSize: CGFloat(sizeSlider.value))
        if isResizeValid {
            pegView.size = CGFloat(sizeSlider.value)
        }
    }

    func setDefaults() {
        bluePegButton.isSelected = true
        canvas.translatesAutoresizingMaskIntoConstraints = false
        selectedPaletteButton = bluePegButton
    }

    private func clearAllSelections() {
        paletteButtons.forEach { $0.isSelected = false }
    }
}
