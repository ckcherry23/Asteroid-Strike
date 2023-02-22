//
//  Gameboard.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

struct Gameboard {
    private(set) var pegs: Set<Peg> = Set<Peg>()
    private(set) var blocks: Set<Block> = Set<Block>()
    private(set) var board: CGPath?

    mutating func addPeg(addedPeg: Peg) {
        guard pegCanBeAdded(addedPeg: addedPeg) else {
            return
        }

        pegs.insert(addedPeg)
    }

    mutating func movePeg(movedPeg: Peg, to newLocation: CGPoint) -> Bool {
        let pegAtNewPosition = Peg(location: newLocation, type: movedPeg.type,
                                   radius: movedPeg.radius, angle: movedPeg.angle)
        return replacePeg(oldPeg: movedPeg, newPeg: pegAtNewPosition)
    }

    mutating func deletePeg(deletedPeg: Peg) {
        pegs.remove(deletedPeg)
    }

    mutating func resizePeg(resizedPeg: Peg, newRadius: CGFloat) -> Bool {
        let pegOfNewSize = Peg(location: resizedPeg.location, type: resizedPeg.type,
                               radius: newRadius, angle: resizedPeg.angle)
        return replacePeg(oldPeg: resizedPeg, newPeg: pegOfNewSize)
    }

    mutating func rotatePeg(rotatedPeg: Peg, to newAngle: CGFloat) -> Bool {
        let pegOfNewAngle = Peg(location: rotatedPeg.location,
                                type: rotatedPeg.type, radius: rotatedPeg.radius, angle: newAngle)
        return replacePeg(oldPeg: rotatedPeg, newPeg: pegOfNewAngle)
    }

    func findPeg(at location: CGPoint) -> Peg? {
        pegs.first(where: { $0.hitBox.contains(location) }) ?? nil
    }

    private mutating func replacePeg(oldPeg: Peg, newPeg: Peg) -> Bool {
        let initialPegCount = pegs.count

        guard contains(peg: oldPeg) else {
            return false
        }

        deletePeg(deletedPeg: oldPeg)

        guard pegCanBeAdded(addedPeg: newPeg) else {
            // add back deleted peg since new position is invalid
            addPeg(addedPeg: oldPeg)
            return false
        }

        addPeg(addedPeg: newPeg)
        let finalPegCount = pegs.count
        assert(initialPegCount == finalPegCount)
        return true
    }

    private func pegCanBeAdded(addedPeg: Peg) -> Bool {
        isPegNotOverlapped(peg: addedPeg) && isPegInsideCanvas(peg: addedPeg)
    }

    private func isPegNotOverlapped(peg: Peg) -> Bool {
        pegs.allSatisfy({ !$0.isOverlapping(gameboardObject: peg) })
        && blocks.allSatisfy({ !$0.isOverlapping(gameboardObject: peg) })
    }

    private func isPegInsideCanvas(peg: Peg) -> Bool {
        guard let board = board else {
            return false
        }
        return peg.isWithin(path: board)
    }

    private func contains(peg: Peg) -> Bool {
        return pegs.contains(peg)
    }
}

// Blocks
extension Gameboard {
    mutating func addBlock(addedBlock: Block) {
        guard blockCanBeAdded(addedBlock: addedBlock) else {
            return
        }

        blocks.insert(addedBlock)
    }

    mutating func moveBlock(movedBlock: Block, to newLocation: CGPoint) -> Bool {
        let blockAtNewPosition = Block(location: newLocation, size: movedBlock.size, angle: movedBlock.angle)
        return replaceBlock(oldBlock: movedBlock, newBlock: blockAtNewPosition)
    }

    mutating func deleteBlock(deletedBlock: Block) {
        blocks.remove(deletedBlock)
    }

    mutating func resizeBlock(resizedBlock: Block, newSize: CGSize) -> Bool {
        let blockWithNewSize = Block(location: resizedBlock.location, size: newSize, angle: resizedBlock.angle)
        return replaceBlock(oldBlock: resizedBlock, newBlock: blockWithNewSize)
    }

    mutating func rotateBlock(rotatedBlock: Block, to newAngle: CGFloat) -> Bool {
        let blockWithNewAngle = Block(location: rotatedBlock.location, size: rotatedBlock.size, angle: newAngle)
        return replaceBlock(oldBlock: rotatedBlock, newBlock: blockWithNewAngle)
    }

    func findBlock(at location: CGPoint) -> Block? {
        blocks.first(where: { $0.hitBox.contains(location) }) ?? nil
    }

    private mutating func replaceBlock(oldBlock: Block, newBlock: Block) -> Bool {
        let initialBlockCount = blocks.count
        guard contains(block: oldBlock) else {
            return false
        }

        deleteBlock(deletedBlock: oldBlock)

        guard blockCanBeAdded(addedBlock: newBlock) else {
            // add back deleted block since new position is invalid
            addBlock(addedBlock: oldBlock)
            return false
        }

        addBlock(addedBlock: newBlock)
        let finalBlockCount = blocks.count
        assert(initialBlockCount == finalBlockCount)
        return true
    }

    private func blockCanBeAdded(addedBlock: Block) -> Bool {
        isBlockNotOverlapped(block: addedBlock) && isBlockInsideCanvas(block: addedBlock)
    }

    private func isBlockNotOverlapped(block: Block) -> Bool {
        pegs.allSatisfy({ !$0.isOverlapping(gameboardObject: block) })
        && blocks.allSatisfy({ !$0.isOverlapping(gameboardObject: block) })
    }

    private func isBlockInsideCanvas(block: Block) -> Bool {
        guard let board = board else {
            return false
        }
        return block.isWithin(path: board)
    }

    private func contains(block: Block) -> Bool {
        return blocks.contains(block)
    }
}

// Utility functions
extension Gameboard {
    mutating func updateBoard(to boardSize: CGSize) {
        self.board = CGPath(rect: CGRect(origin: CGPoint(), size: boardSize), transform: nil)
    }

    func copy() -> Gameboard {
        var copy = Gameboard(board: board)
        pegs.forEach({ copy.addPeg(addedPeg: $0.copy()) })
        blocks.forEach({ copy.addBlock(addedBlock: $0.copy()) })
        return copy
    }

    static func getDefaultGameboard(of size: CGSize) -> Gameboard {
        var defaultGameboard = Gameboard(pegs: Set<Peg>([Peg(location: CGPoint(x: 300, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 400, y: 400), type: .blue),
                                                         Peg(location: CGPoint(x: 50, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 100, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 200, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 250, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 300, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 100, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 200), type: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 250), type: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 200, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 250, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 300, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 350, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 400, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 450, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 500, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 550, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 600, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 650, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 700, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 750, y: 300), type: .blue),
                                                         Peg(location: CGPoint(x: 200, y: 600), type: .orange),
                                                         Peg(location: CGPoint(x: 500, y: 600), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 600), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 550), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 500), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 450), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 400), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 350), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 250), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 200), type: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 150), type: .orange)]))
        defaultGameboard.updateBoard(to: size)
        return defaultGameboard
    }
}

extension Gameboard: Codable {
    private enum CodingKeys: String, CodingKey {
        // `board` is not stored as it is different for each screen size
        case pegs
        case blocks
    }
}
