//
//  LevelDesigner.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

struct LevelDesigner {
    private(set) var gameboard: Gameboard = Gameboard()

    mutating func addPegToGameboard(pegLocation: CGPoint, pegType: PegType) {
        let addedPeg = Peg(location: pegLocation, type: pegType)
        gameboard.addPeg(addedPeg: addedPeg)
    }

    mutating func addBlockToGameboard(blockLocation: CGPoint) {
        let addedBlock = Block(location: blockLocation)
        gameboard.addBlock(addedBlock: addedBlock)
    }

    mutating func moveObjectOnGameboard(oldLocation: CGPoint, newLocation: CGPoint) -> Bool {
        if let movedPeg = gameboard.findPeg(at: oldLocation) {
            return gameboard.movePeg(movedPeg: movedPeg, to: newLocation)
        } else if let movedBlock = gameboard.findBlock(at: oldLocation) {
            return gameboard.moveBlock(movedBlock: movedBlock, to: newLocation)
        }
        return false
    }

    mutating func eraseObjectFromGameboard(tappedLocation: CGPoint) {
        if let erasedPeg = gameboard.findPeg(at: tappedLocation) {
            gameboard.deletePeg(deletedPeg: erasedPeg)
        } else if let erasedBlock = gameboard.findBlock(at: tappedLocation) {
            gameboard.deleteBlock(deletedBlock: erasedBlock)
        }
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
