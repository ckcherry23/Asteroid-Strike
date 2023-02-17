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
    private static var defaultGravity: CGVector = CGVector(dx: 0, dy: 200)

    private var physicsBodies: [PhysicsBody] = []

    static var gravity: CGVector = defaultGravity

    var frameRate: Float = PhysicsWorld.defaultFrameRate
    var origin: CGPoint = CGPoint.zero

    let collisionResolvers: [any CollisionResolver] = [ImpulseResolver(), PositionResolver()]

    func addPhysicsBody(phyicsBody: PhysicsBody) {
        physicsBodies.append(phyicsBody)
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
            }
        }
    }
}
