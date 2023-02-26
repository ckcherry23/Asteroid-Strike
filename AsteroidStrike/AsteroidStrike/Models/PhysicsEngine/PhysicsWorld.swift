//
//  PhysicsWorld.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 4/2/23.
//  Referenced from https://developer.apple.com/documentation/spritekit
//

import Foundation

class PhysicsWorld {
    private static var defaultFrameRate: Float = 60
    private static var defaultGravity = CGVector(dx: 0, dy: 200)

    private var physicsBodies: [PhysicsBody] = []

    static var gravity: CGVector = defaultGravity

    var frameRate: Float = PhysicsWorld.defaultFrameRate
    var origin = CGPoint.zero

    let collisionResolvers: [any CollisionResolver] = [ImpulseResolver()]

    var collisionDelegate: PhysicsCollisionDelegate?

    func addPhysicsBody(physicsBody: PhysicsBody) {
        physicsBodies.append(physicsBody)
    }

    func removePhysicsBody(physicsBody: PhysicsBody) {
        physicsBodies.removeAll(where: { $0 === physicsBody })
    }

    func findPhysicsBody(at location: CGPoint) -> PhysicsBody? {
        physicsBodies.first(where: { $0.contains(point: location) })
    }

    func getBodiesInContact(with physicsBody: PhysicsBody) -> [PhysicsBody] {
        physicsBodies.filter({ physicsBody.isIntersecting(other: $0) })
    }

    func getBodiesNear(body: PhysicsBody, radius: CGFloat) -> [PhysicsBody] {
        physicsBodies.filter({ $0.position.distanceFrom(other: body.position) <= radius })
    }
}

extension PhysicsWorld {
    func updateWorld() {
        physicsBodies.forEach({ $0.updateBody(timeInterval: TimeInterval(1 / frameRate)) })
        detectAndResolveCollisions()
    }

    private func detectAndResolveCollisions() {
        for firstBody in physicsBodies {
            for secondBody in physicsBodies {
                guard firstBody !== secondBody else {
                    break
                }
                guard let bodiesCollision = firstBody.detectCollision(other: secondBody) else {
                    continue
                }
                bodiesCollision.resolveCollision(resolvers: collisionResolvers)
                collisionDelegate?.onCollision(physicsCollision: bodiesCollision)
            }
        }
    }
}
