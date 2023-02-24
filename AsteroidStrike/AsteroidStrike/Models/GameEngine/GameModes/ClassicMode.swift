//
//  ClassicMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import Foundation

class ClassicMode: GameMode {
    var totalBallsCount: Int
    var timeLimit: TimeInterval = TimeInterval.infinity
    unowned var gameEngine: GameEngine

    init(gameEngine: GameEngine, totalBallsCount: Int = 10) {
        self.gameEngine = gameEngine
        self.totalBallsCount = totalBallsCount
    }

    var hasWon: Bool {
        gameEngine.remainingOrangePegsCount == 0
    }

    var hasLost: Bool {
        gameEngine.remainingBallsCount <= 0
        && gameEngine.remainingOrangePegsCount > 0
        && gameEngine.hasLaunchEnded
    }

    func onEnterBucket() {
        gameEngine.updateBallCount(1)
    }
}
