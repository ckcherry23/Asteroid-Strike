//
//  SpookyBallPowerup.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

class SpookyBallPowerup: Powerup {
    unowned var gameEngine: GameEngine
    private var remainingNumberOfSpookyBalls = 0

    init(gameEngine: GameEngine) {
        self.gameEngine = gameEngine
    }

    var isPowerupActivated: Bool {
        getActivatedPowerups(gameEngine: gameEngine).count > 0
    }

    func handlePowerup() {
        guard isPowerupActivated else {
            return
        }
        gameEngine.isSpookyBallActivated = true
    }

    func getPowerupsToDeactivate() -> [Peg] {
        guard let powerupToDeactivate = getActivatedPowerups(gameEngine: gameEngine).first else {
            return []
        }
        return [powerupToDeactivate]
    }
}
