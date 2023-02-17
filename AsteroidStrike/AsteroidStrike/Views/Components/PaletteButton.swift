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

    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customize()
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

    private func customize() {
        layer.cornerRadius = bounds.size.width / 2
    }
}
