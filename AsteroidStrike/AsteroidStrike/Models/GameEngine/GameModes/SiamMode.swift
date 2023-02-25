//
//  SiamMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 25/2/23.
//

import Foundation

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
