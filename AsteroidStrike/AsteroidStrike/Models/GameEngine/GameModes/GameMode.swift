//
//  GameMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 23/2/23.
//

import Foundation

protocol GameMode {
    var totalBallsCount: Int { get }
    var timeLimit: TimeInterval { get }
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

class BeatTheScoreMode: GameMode {
    var totalBallsCount: Int = Int.max
    var timeLimit: TimeInterval
    var scoreToBeat: Int
    unowned var gameEngine: GameEngine

    init(gameEngine: GameEngine, gameboard: Gameboard) {
        self.gameEngine = gameEngine
        (timeLimit, scoreToBeat) = ScoreHelper.calculateBeatTheScoreGameConditions(for: gameboard)
    }

    var hasWon: Bool {
        gameEngine.score > scoreToBeat
    }

    var hasLost: Bool {
        gameEngine.timeRemaining == 0 && gameEngine.score < scoreToBeat
    }

    func onEnterBucket() {
        gameEngine.updateTimeLeft(10)
    }
}

class SiamMode: GameMode {
    var totalBallsCount: Int
    var timeLimit: TimeInterval = TimeInterval.infinity
    unowned var gameEngine: GameEngine

    init(gameEngine: GameEngine, totalBallsCount: Int = 3) {
        self.totalBallsCount = totalBallsCount
        self.gameEngine = gameEngine
    }

    var hasWon: Bool {
        gameEngine.remainingBallsCount == 0 && gameEngine.hitPegsCount == 0
    }

    var hasLost: Bool {
        gameEngine.hitPegsCount > 0
    }

    func onEnterBucket() {
        gameEngine.updateBallCount(-1)
    }
}

class ScoreHelper {
    static func calculateBeatTheScoreGameConditions(for gameboard: Gameboard) -> (TimeInterval, Int) {
        return (120, 1200)
    }
}
