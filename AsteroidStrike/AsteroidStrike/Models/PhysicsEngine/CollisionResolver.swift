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
        if collision.firstBody.isCollidableWith(other: collision.secondBody) {
            collision.firstBody.applyImpulse(impulse: -impulseVector)
        }
        if collision.secondBody.isCollidableWith(other: collision.firstBody) {
            collision.secondBody.applyImpulse(impulse: impulseVector)
        }
    }
}

class PositionResolver: CollisionResolver {
    func resolve(collision: PhysicsCollision) {

    }
}
