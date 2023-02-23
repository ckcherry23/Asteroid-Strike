//
//  KaboomPowerup.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

class KaboomPowerup: Powerup {
    unowned var gameEngine: GameEngine
    var isPowerupActivated: Bool {
        getGreenHitPegs(gameEngine: gameEngine).count > 0
    }

    init(gameEngine: GameEngine) {
        self.gameEngine = gameEngine
        gameEngine.physicsWorld.collisionDelegate = ExplosionDelegate()
    }

    deinit {
        gameEngine.physicsWorld.collisionDelegate = nil
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
