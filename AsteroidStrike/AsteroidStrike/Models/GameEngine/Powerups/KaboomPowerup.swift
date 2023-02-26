//
//  KaboomPowerup.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import CoreGraphics

class KaboomPowerup: Powerup {
    unowned var gameEngine: GameEngine
    private var blastRadius: CGFloat = 200

    var isPowerupActivated: Bool {
        !getActivatedPowerups(gameEngine: gameEngine).isEmpty
    }

    init(gameEngine: GameEngine) {
        self.gameEngine = gameEngine
        gameEngine.physicsWorld.collisionDelegate = ExplosionDelegate()
    }

    deinit {
        gameEngine.physicsWorld.collisionDelegate = nil
    }

    func handlePowerup() {
        guard isPowerupActivated else {
            return
        }
        gameEngine.destroyNearbyPegs(radius: blastRadius)
    }

    func getPowerupsToDeactivate() -> [Peg] {
        getActivatedPowerups(gameEngine: gameEngine)
    }
}
