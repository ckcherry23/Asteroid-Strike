//
//  BeatTheScoreMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 25/2/23.
//

import Foundation

class BeatTheScoreMode: GameMode {
    var isTimerNeeded: Bool = true
    var hasTargetScore: Bool = true
    var totalBallsCount: Int = Int.max
    var timeLimit: TimeInterval
    var targetScore: Int
    unowned var gameEngine: GameEngine

    init(gameEngine: GameEngine) {
        self.gameEngine = gameEngine
        (timeLimit, targetScore) = ScoreHelper.calculateGameConditions(for: gameEngine.gameboard)
    }

    var hasWon: Bool {
        gameEngine.gameStats.score >= targetScore
    }

    var hasLost: Bool {
        gameEngine.gameStats.timeRemaining <= 0
        && gameEngine.gameStats.score < targetScore
        && gameEngine.areAllScoresCalculated
    }

    func onEnterBucket() {
        gameEngine.updateTimeLeft(5)
    }

    class ScoreHelper {
        static func calculateGameConditions(for gameboard: Gameboard) -> (TimeInterval, Int) {
            let maxScore = gameboard.pegs.reduce(0, { partialResult, peg in
                partialResult + (PegType.pegScoreMapping[peg.type] ?? 0) })
            let scoreToBeat = maxScore * 2 / 3
            let timeRequired = TimeInterval(gameboard.pegs.count)
            return (timeRequired, scoreToBeat)
        }
    }
}
