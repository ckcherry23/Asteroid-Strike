//
//  BeatTheScoreMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 25/2/23.
//

import Foundation

class BeatTheScoreMode: GameMode {
    var isTimerNeeded = true
    var hasTargetScore = true
    var totalBallsCount = Int.max
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

            let minTime = TimeInterval(10)
            let pegCountScaled = Double(gameboard.pegs.count) * 5
            let powerupDeficit = Double((gameboard.pegs.filter({ $0.type == .green }).count + 1))
            let timeRequired = max(TimeInterval(pegCountScaled / powerupDeficit), minTime).rounded()
            return (timeRequired, scoreToBeat)
        }
    }
}
