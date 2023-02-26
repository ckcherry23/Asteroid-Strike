//
//  ClassicMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import Foundation

class ClassicMode: GameMode {
    var isTimerNeeded = false
    var hasTargetScore = false
    var totalBallsCount: Int
    var timeLimit = TimeInterval.infinity
    var targetScore: Int = 0
    unowned var gameEngine: GameEngine

    init(gameEngine: GameEngine, totalBallsCount: Int = 10) {
        self.gameEngine = gameEngine
        self.totalBallsCount = totalBallsCount
    }

    var hasWon: Bool {
        gameEngine.remainingOrangePegsCount <= 0
    }

    var hasLost: Bool {
        gameEngine.gameStats.remainingBallsCount <= 0
        && gameEngine.remainingOrangePegsCount > 0
        && gameEngine.hasLaunchEnded
        && gameEngine.areAllScoresCalculated
    }

    func onEnterBucket() {
        gameEngine.updateBallCount(1)
    }
}
