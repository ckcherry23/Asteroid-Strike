//
//  Powerup.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

protocol Powerup {
    var isPowerupActivated: Bool { get }
    func handlePowerup()
    func getPowerupsToDeactivate() -> [Peg]
}

extension Powerup {
    func getActivatedPowerups(gameEngine: GameEngine) -> [Peg] {
        gameEngine.gameboard.pegs.filter({ $0.type == .green && $0.isHit
            && $0.physicsBody.categoryBitmask == PhysicsBodyCategory.activePowerup})
    }

    func deactivateUsedPowerups(powerups: [Peg]) {
        powerups.forEach({
            $0.physicsBody.categoryBitmask = PhysicsBodyCategory.deactivatedPowerup
        })
    }
}
