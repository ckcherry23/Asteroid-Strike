//
//  PaletteButton.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import UIKit

class PaletteButton: UIButton {
    override var isSelected: Bool {
        didSet {
            updatePaletteButtonAppearance()
        }
    }

    private func updatePaletteButtonAppearance() {
        if isSelected {
            layer.borderWidth = 2.0
            layer.borderColor = UIColor.tintColor.cgColor
        } else {
            layer.borderWidth = 0.0
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}
