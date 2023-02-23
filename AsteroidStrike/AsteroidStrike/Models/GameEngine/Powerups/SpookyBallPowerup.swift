//
//  SpookyBallPowerup.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

class SpookyBallPowerup: Powerup {
    var isPowerupActivated: Bool {
        getGreenHitPegs(gameEngine: gameEngine).count > 0
    }

    func handlePowerup() {

    }

    unowned var gameEngine: GameEngine

    init(gameEngine: GameEngine) {
        self.gameEngine = gameEngine
    }
}
