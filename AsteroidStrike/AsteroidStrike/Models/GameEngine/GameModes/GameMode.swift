//
//  GameMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 23/2/23.
//

import Foundation

protocol GameMode {
    var isTimerNeeded: Bool { get }
    var hasTargetScore: Bool { get }
    var totalBallsCount: Int { get }
    var timeLimit: TimeInterval { get }
    var targetScore: Int { get }
    var hasWon: Bool { get }
    var hasLost: Bool { get }
    func isGameOver() -> Bool
    func onEnterBucket()
}

extension GameMode {
    func isGameOver() -> Bool {
        hasWon || hasLost
    }
}

class SiamMode: GameMode {
    var isTimerNeeded: Bool = false
    var hasTargetScore: Bool = false
    var totalBallsCount: Int
    var timeLimit: TimeInterval = TimeInterval.infinity
    var targetScore: Int = 0
    unowned var gameEngine: GameEngine

    init(gameEngine: GameEngine, totalBallsCount: Int = 3) {
        self.totalBallsCount = totalBallsCount
        self.gameEngine = gameEngine
    }

    var hasWon: Bool {
        gameEngine.gameStats.remainingBallsCount == 0 && gameEngine.hitPegsCount == 0
    }

    var hasLost: Bool {
        gameEngine.hitPegsCount > 0
    }

    func onEnterBucket() {
        gameEngine.updateBallCount(-1)
    }
}

enum GameModeType {
    case classic
    case beatTheScore
    case siam

    static let gameModeMapping: [GameModeType: (GameEngine) -> (GameMode)] = [
        .classic: { (gameEngine) in ClassicMode(gameEngine: gameEngine) },
        .beatTheScore: { (gameEngine) in BeatTheScoreMode(gameEngine: gameEngine) },
        .siam: { (gameEngine) in SiamMode(gameEngine: gameEngine) }
    ]
}
