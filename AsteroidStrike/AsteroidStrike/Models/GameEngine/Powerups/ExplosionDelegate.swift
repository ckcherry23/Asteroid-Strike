//
//  ExplosionDelegate.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import CoreGraphics
import Foundation

class ExplosionDelegate: PhysicsCollisionDelegate {
    func onCollision(physicsCollision: PhysicsCollision) {
        applyExplosionImpulse(physicsCollision: physicsCollision)
    }

    private func applyExplosionImpulse(physicsCollision: PhysicsCollision) {
        let xComponent = Double.random(in: -800...800)
        let yComponent = Double.random(in: 400...800) * (-1)
        let explosionImpulse = CGVector(dx: xComponent, dy: yComponent)
        if physicsCollision.firstBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.secondBody.applyImpulse(impulse: explosionImpulse)
        } else if physicsCollision.secondBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.firstBody.applyImpulse(impulse: explosionImpulse)
        }
    }
}
