//
//  LevelDesigner.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

class LevelDesigner {
    var observers: [Observer] = []
    private(set) var gameboard = Gameboard() {
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

    // TODO: Polymorphism
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
    func resizePegOnGameboard(pegLocation: CGPoint, newSize: CGFloat) -> Bool {
        guard let resizedPeg = gameboard.findPeg(at: pegLocation) else {
            return false
        }
        return gameboard.resizePeg(resizedPeg: resizedPeg, newRadius: newSize / 2)
    }

    func resizeBlockOnGameboard(blockLocation: CGPoint, newSize: CGSize) -> Bool {
        guard let resizedBlock = gameboard.findBlock(at: blockLocation) else {
            return false
        }
        return gameboard.resizeBlock(resizedBlock: resizedBlock, newSize: newSize)
    }

    func rotateObjectOnGameboard(location: CGPoint, newAngle: CGFloat) -> Bool {
        if let rotatedPeg = gameboard.findPeg(at: location) {
            return gameboard.rotatePeg(rotatedPeg: rotatedPeg, to: newAngle)
        } else if let rotatedBlock = gameboard.findBlock(at: location) {
            return gameboard.rotateBlock(rotatedBlock: rotatedBlock, to: newAngle)
        }
        return false
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
