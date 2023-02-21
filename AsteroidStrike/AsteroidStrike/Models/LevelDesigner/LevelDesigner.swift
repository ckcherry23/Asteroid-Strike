//
//  LevelDesigner.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

struct LevelDesigner {
    private(set) var gameboard: Gameboard = Gameboard()

    mutating func addPegToGameboard(pegLocation: CGPoint, pegColor: PegColor) {
        let addedPeg = Peg(location: pegLocation, color: pegColor)
        gameboard.addPeg(addedPeg: addedPeg)
    }

    mutating func movePegOnGameboard(oldLocation: CGPoint, newLocation: CGPoint) -> Bool {
        guard let movedPeg = gameboard.findPeg(at: oldLocation) else {
            return false
        }
        return gameboard.movePeg(movedPeg: movedPeg, to: newLocation)
    }

    mutating func erasePegFromGameboard(tappedLocation: CGPoint) {
        guard let erasedPeg = gameboard.findPeg(at: tappedLocation) else {
            return
        }
        gameboard.deletePeg(deletedPeg: erasedPeg)
    }

    mutating func addBlockToGameboard(blockLocation: CGPoint) {
        let addedBlock = Block(location: blockLocation)
        gameboard.addBlock(addedBlock: addedBlock)
    }
}

extension LevelDesigner {
    mutating func updateCanvasSize(_ canvasSize: CGSize) {
        gameboard.updateBoard(to: canvasSize)
    }

    mutating func updateGameboardFromLoadedLevel(savedLevel: SavedLevel) {
        gameboard = savedLevel.gameBoard
    }
}
