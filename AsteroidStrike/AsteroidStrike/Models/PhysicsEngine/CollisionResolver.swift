//
//  CollisionResolver.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 11/2/23.
//

protocol CollisionResolver {
    func resolve(collision: PhysicsCollision)
}

class ImpulseResolver: CollisionResolver {
    func resolve(collision: PhysicsCollision) {
        let impulseVector = collision.contactNormal * collision.impulse
        collision.firstBody.applyImpulse(impulse: -impulseVector)
        collision.secondBody.applyImpulse(impulse: impulseVector)
    }
}

class PositionResolver: CollisionResolver {
    func resolve(collision: PhysicsCollision) {

    }
}
