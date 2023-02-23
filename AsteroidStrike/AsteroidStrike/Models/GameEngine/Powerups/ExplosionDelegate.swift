//
//  ExplosionDelegate.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import CoreGraphics

class ExplosionDelegate: PhysicsCollisionDelegate {
    func onCollision(physicsCollision: PhysicsCollision) {
        let explosionImpulse = CGVector(dx: -400, dy: -400)
        if physicsCollision.firstBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.secondBody.applyImpulse(impulse: explosionImpulse)
        } else if physicsCollision.secondBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.firstBody.applyImpulse(impulse: explosionImpulse)
        }
    }
}
