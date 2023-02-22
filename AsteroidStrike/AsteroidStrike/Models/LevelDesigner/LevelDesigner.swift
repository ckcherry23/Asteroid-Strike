//
//  LevelDesigner.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

class LevelDesigner {
    var observers: [Observer] = []
    private(set) var gameboard: Gameboard = Gameboard() {
        didSet {
            notify()
        }
    }

    func addPegToGameboard(pegLocation: CGPoint, pegType: PegType) {
        let addedPeg = Peg(location: pegLocation, type: pegType)
        gameboard.addPeg(addedPeg: addedPeg)
    }

    func addBlockToGameboard(blockLocation: CGPoint) {
        let addedBlock = Block(location: blockLocation)
        gameboard.addBlock(addedBlock: addedBlock)
    }

    func moveObjectOnGameboard(oldLocation: CGPoint, newLocation: CGPoint) -> Bool {
        if let movedPeg = gameboard.findPeg(at: oldLocation) {
            return gameboard.movePeg(movedPeg: movedPeg, to: newLocation)
        } else if let movedBlock = gameboard.findBlock(at: oldLocation) {
            return gameboard.moveBlock(movedBlock: movedBlock, to: newLocation)
        }
        return false
    }

    func eraseObjectFromGameboard(tappedLocation: CGPoint) {
        if let erasedPeg = gameboard.findPeg(at: tappedLocation) {
            gameboard.deletePeg(deletedPeg: erasedPeg)
        } else if let erasedBlock = gameboard.findBlock(at: tappedLocation) {
            gameboard.deleteBlock(deletedBlock: erasedBlock)
        }
    }
}

extension LevelDesigner {
    func updateCanvasSize(_ canvasSize: CGSize) {
        gameboard.updateBoard(to: canvasSize)
    }

    func updateGameboardFromLoadedLevel(savedLevel: SavedLevel) {
        gameboard = savedLevel.gameBoard
    }
}

extension LevelDesigner: Observable {
    func attach(observer: Observer) {
        observers.append(observer)
    }
    func detach(observer: Observer) {
        guard let removedIndex = observers.firstIndex(where: { $0 === observer }) else {
            return
        }
        observers.remove(at: removedIndex)
    }
    func notify() {
        observers.forEach({ $0.update() })
    }
}
