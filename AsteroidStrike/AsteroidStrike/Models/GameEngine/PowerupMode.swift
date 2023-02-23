//
//  PowerupMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import CoreGraphics

enum PowerupMode {
    case kaboom
    case spookyBall

    static let powerupMapping: [PowerupMode: (GameEngine) -> (Powerup)] = [
        .kaboom: { (gameEngine) in KaboomPowerup(gameEngine: gameEngine) },
        .spookyBall: { (gameEngine) in SpookyBallPowerup(gameEngine: gameEngine) }
    ]
}

protocol Powerup {
    var isPowerupActivated: Bool { get }
    func handlePowerup()
}

extension Powerup {
    func getGreenHitPegs(gameEngine: GameEngine) -> [Peg] {
        gameEngine.gameboard.pegs.filter({ $0.type == .green && $0.isHit })
    }
}

class KaboomPowerup: Powerup {
    unowned var gameEngine: GameEngine
    var isPowerupActivated: Bool {
        getGreenHitPegs(gameEngine: gameEngine).count > 0
    }

    init(gameEngine: GameEngine) {
        self.gameEngine = gameEngine
        gameEngine.physicsWorld.collisionDelegate = ExplosionDelegate()
    }

    private func getKaboomPegs() -> [Peg] {
        getGreenHitPegs(gameEngine: gameEngine)
    }

    func handlePowerup() {
        guard isPowerupActivated else {
            return
        }
        let kaboomPegs = getKaboomPegs()
        kaboomPegs.forEach({ kaboomPeg in
            kaboomPeg.physicsBody.categoryBitmask = PhysicsBodyCategory.all
            gameEngine.physicsWorld.getBodiesNear(body: kaboomPeg.physicsBody, radius: 200)
            .forEach({
                $0.hitCounter += 1
                $0.categoryBitmask = PhysicsBodyCategory.all
            }) })
    }
}

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
