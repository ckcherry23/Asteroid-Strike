//
//  ExplosionDelegate.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import CoreGraphics

class ExplosionDelegate: PhysicsCollisionDelegate {
    func onCollision(physicsCollision: PhysicsCollision) {
        applyExplosionImpulse(physicsCollision: physicsCollision)
    }

    private func applyExplosionImpulse(physicsCollision: PhysicsCollision) {
        let explosionImpulse = CGVector(dx: -800, dy: -800)
        if physicsCollision.firstBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.secondBody.applyImpulse(impulse: explosionImpulse)
        } else if physicsCollision.secondBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.firstBody.applyImpulse(impulse: explosionImpulse)
        }
    }
}
