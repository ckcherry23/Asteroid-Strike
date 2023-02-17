//
//  Gameboard.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

struct Gameboard: Codable {
    private(set) var pegs: Set<Peg> = Set<Peg>()
    private(set) var board: CGPath?

    private enum CodingKeys: String, CodingKey {
        // `board` is not stored as it is different for each screen size
        case pegs
    }

    mutating func addPeg(addedPeg: Peg) {
        guard pegCanBeAdded(addedPeg: addedPeg) else {
            return
        }

        pegs.insert(addedPeg)
    }

    mutating func movePeg(movedPeg: Peg, to newLocation: CGPoint) -> Bool {
        let initialPegCount = pegs.count
        let pegAtNewPosition = Peg(location: newLocation, color: movedPeg.color)

        guard contains(peg: movedPeg) else {
            return false
        }

        deletePeg(deletedPeg: movedPeg)

        guard pegCanBeAdded(addedPeg: pegAtNewPosition) else {
            // add back deleted peg since new position is invalid
            addPeg(addedPeg: movedPeg)
            return false
        }

        addPeg(addedPeg: pegAtNewPosition)
        let finalPegCount = pegs.count
        assert(initialPegCount == finalPegCount)
        return true
    }

    mutating func deletePeg(deletedPeg: Peg) {
        pegs.remove(deletedPeg)
    }

    func findPeg(at location: CGPoint) -> Peg? {
        pegs.first(where: { $0.hitBox.contains(location) }) ?? nil
    }

    mutating func updateBoard(to boardSize: CGSize) {
        self.board = CGPath(rect: CGRect(origin: CGPoint(), size: boardSize), transform: nil)
    }

    private func pegCanBeAdded(addedPeg: Peg) -> Bool {
        isPegNotOverlapped(peg: addedPeg) && isPegInsideCanvas(peg: addedPeg)
    }

    private func isPegNotOverlapped(peg: Peg) -> Bool {
        pegs.allSatisfy({ !$0.isOverlapping(gameboardObject: peg) })
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

    static func getDefaultGameboard(of size: CGSize) -> Gameboard {
        var defaultGameboard = Gameboard(pegs: Set<Peg>([Peg(location: CGPoint(x: 300, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 400, y: 400), color: .blue),
                                                         Peg(location: CGPoint(x: 50, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 100, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 200, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 250, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 300, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 100, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 200), color: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 250), color: .blue),
                                                         Peg(location: CGPoint(x: 150, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 200, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 250, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 300, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 350, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 400, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 450, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 500, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 550, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 600, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 650, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 700, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 750, y: 300), color: .blue),
                                                         Peg(location: CGPoint(x: 200, y: 600), color: .orange),
                                                         Peg(location: CGPoint(x: 500, y: 600), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 600), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 550), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 500), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 450), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 400), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 350), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 250), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 200), color: .orange),
                                                         Peg(location: CGPoint(x: 700, y: 150), color: .orange)]))
        defaultGameboard.updateBoard(to: size)
        return defaultGameboard
    }
}
