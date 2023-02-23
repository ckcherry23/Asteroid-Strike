//
//  ExplosionDelegate.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

import CoreGraphics

class ExplosionDelegate: PhysicsCollisionDelegate {
    func onCollision(physicsCollision: PhysicsCollision) {
        let impulse = CGVector(dx: -400, dy: -400)
        if physicsCollision.firstBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.secondBody.applyImpulse(impulse: impulse)
        } else if physicsCollision.secondBody.categoryBitmask == PhysicsBodyCategory.activePowerup {
            physicsCollision.firstBody.applyImpulse(impulse: impulse)
        }
    }
}

struct PhysicsBodyCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let ball: UInt32 = UInt32.max
    static let activePowerup: UInt32 = 0b10
}
