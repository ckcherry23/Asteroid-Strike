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

    @IBAction func onWidthSliderValueChanged(_ sender: UISlider) {
        guard let blockView = selectedCanvasObject as? BlockView else {
            return
        }
        let isResizeValid = levelDesigner.resizeBlockOnGameboard(
            blockLocation: blockView.location,
            newSize: CGSize(width: CGFloat(widthSlider.value), height: blockView.size.height))
        if isResizeValid {
            blockView.setSize(newSize: CGSize(width: CGFloat(widthSlider.value), height: blockView.size.height))
        }
    }

    @IBAction func onHeightSliderValueChanged(_ sender: UISlider) {
        guard let blockView = selectedCanvasObject as? BlockView else {
            return
        }
        let isResizeValid = levelDesigner.resizeBlockOnGameboard(
            blockLocation: blockView.location,
            newSize: CGSize(width: blockView.size.width, height: CGFloat(heightSlider.value)))
        if isResizeValid {
            blockView.setSize(newSize: CGSize(width: blockView.size.width, height: CGFloat(heightSlider.value)))
        }
    }

    @IBAction func onRotationSliderValueChanged(_ sender: UISlider) {

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
