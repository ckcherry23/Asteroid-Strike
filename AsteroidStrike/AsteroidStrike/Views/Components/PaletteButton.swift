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

    func getModifyGameboardClosure(levelDesigner: LevelDesigner) -> (CGPoint) -> Void {{ _ in () }}
}

class BluePegButton: PaletteButton {
    override func getModifyGameboardClosure(levelDesigner: LevelDesigner) -> (CGPoint) -> Void {
        { (tappedLocation) in levelDesigner.addPegToGameboard(pegLocation: tappedLocation, pegType: .blue) }
    }
}

class OrangePegButton: PaletteButton {
    override func getModifyGameboardClosure(levelDesigner: LevelDesigner) -> (CGPoint) -> Void {
        { (tappedLocation) in levelDesigner.addPegToGameboard(pegLocation: tappedLocation, pegType: .orange) }
    }
}

class BlockButton: PaletteButton {
    override func getModifyGameboardClosure(levelDesigner: LevelDesigner) -> (CGPoint) -> Void {
        { (tappedLocation) in levelDesigner.addBlockToGameboard(blockLocation: tappedLocation) }
    }
}

class EraseButton: PaletteButton {
    override func getModifyGameboardClosure(levelDesigner: LevelDesigner) -> (CGPoint) -> Void {
        { (tappedLocation) in levelDesigner.eraseObjectFromGameboard(tappedLocation: tappedLocation) }
    }
}
