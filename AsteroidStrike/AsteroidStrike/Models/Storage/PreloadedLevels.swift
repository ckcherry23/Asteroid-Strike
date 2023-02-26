//
//  PreloadedLevels.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 26/2/23.
//

import CoreGraphics

struct PreloadedLevels {
    static var preloadedLevelNames = ["Hot in the Corners", "We're Skewed", "Harry Power"]
    var size: CGSize
    var preloadedLevels: [SavedLevel] = []
    let defaultBoard = CGPath(rect: CGRect(origin: CGPoint(), size: CGSize(width: 800, height: 800)), transform: nil)

    private var cornersLevel: SavedLevel {
        SavedLevel(gameBoard: Gameboard(
            pegs: Set<Peg>([
                Peg(location: CGPoint(x: 25, y: 25), type: .orange),
                Peg(location: CGPoint(x: 775, y: 775), type: .orange),
                Peg(location: CGPoint(x: 775, y: 25), type: .blue),
                Peg(location: CGPoint(x: 25, y: 770), type: .blue)
            ]),
            blocks: Set<Block>([
                Block(location: CGPoint(x: 200, y: 400)),
                Block(location: CGPoint(x: 600, y: 400))
            ]),
            board: defaultBoard
        ), levelName: "Hot in the Corners")
    }

    private var rotateAndResizeLevel: SavedLevel {
        SavedLevel(gameBoard: Gameboard(
            pegs: Set<Peg>([
                Peg(location: CGPoint(x: 500, y: 100), type: .blue, angle: .pi),
                Peg(location: CGPoint(x: 400, y: 400), type: .orange, radius: 35),
                Peg(location: CGPoint(x: 200, y: 700), type: .orange, radius: 50)
            ]),
            blocks: Set<Block>([
                Block(location: CGPoint(x: 200, y: 300), size: CGSize(width: 200, height: 100)),
                Block(location: CGPoint(x: 600, y: 600), angle: -(.pi / 4))
            ]),
            board: defaultBoard
        ), levelName: "We're Skewed")
    }

    private var powerupsLevel: SavedLevel {
        SavedLevel(gameBoard: Gameboard(
            pegs: Set<Peg>([
                Peg(location: CGPoint(x: 510, y: 190), type: .blue),
                Peg(location: CGPoint(x: 540, y: 330), type: .green),
                Peg(location: CGPoint(x: 460, y: 400), type: .orange),
                Peg(location: CGPoint(x: 200, y: 700), type: .blue),
                Peg(location: CGPoint(x: 100, y: 270), type: .blue),
                Peg(location: CGPoint(x: 200, y: 620), type: .green),
                Peg(location: CGPoint(x: 300, y: 640), type: .orange),
                Peg(location: CGPoint(x: 450, y: 300), type: .orange),
                Peg(location: CGPoint(x: 630, y: 580), type: .orange)
            ]),
            board: defaultBoard
        ), levelName: "Harry Power")
    }

    init(size: CGSize) {
        self.size = size
        preloadedLevels.append(getScaledLevel(level: cornersLevel, size: size))
        preloadedLevels.append(getScaledLevel(level: rotateAndResizeLevel, size: size))
        preloadedLevels.append(getScaledLevel(level: powerupsLevel, size: size))
    }

    func getPreloadedLevelNames() -> [String] {
        preloadedLevels.map { $0.levelName }
    }

    private func getScaledLevel(level: SavedLevel, size: CGSize) -> SavedLevel {
        let scaleFactor = size.width / level.gameBoard.board.boundingBox.size.width
        var scaledGameboard = Gameboard()

        scaledGameboard.updateBoard(to: size)
        level.gameBoard.pegs.forEach({ scaledGameboard.addPeg(addedPeg: $0.scale(by: scaleFactor)) })
        level.gameBoard.blocks.forEach({ scaledGameboard.addBlock(addedBlock: $0.scale(by: scaleFactor)) })

        let scaledLevel = SavedLevel(gameBoard: scaledGameboard, levelName: level.levelName)
        return scaledLevel
    }
}
