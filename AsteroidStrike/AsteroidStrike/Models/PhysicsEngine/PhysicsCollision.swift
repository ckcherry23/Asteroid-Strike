//
//  PhysicsCollision.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 4/2/23.
//  Referenced from: https://gamedevelopment.tutsplus.com/tutorials/
//                   how-to-create-a-custom-2d-physics-engine-the-basics-and-impulse-resolution--gamedev-6331
//

import CoreGraphics

class PhysicsCollision {
    var firstBody: PhysicsBody
    var secondBody: PhysicsBody
    var contactNormal: CGVector
    var impulse: CGFloat

    private init?(firstBody: PhysicsBody, secondBody: PhysicsBody, contactNormal: CGVector) {
        self.firstBody = firstBody
        self.secondBody = secondBody
        self.contactNormal = contactNormal

        let relativeVelocity: CGVector = secondBody.velocity - firstBody.velocity
        let velocityAlongNormal: CGFloat = relativeVelocity * contactNormal

        guard velocityAlongNormal <= 0 else {
            return nil
        }

        let collisionRestitution = min(firstBody.restitution, secondBody.restitution)
        var collisionImpulse = -(1 + collisionRestitution) * velocityAlongNormal
        collisionImpulse /= (1 / firstBody.mass + 1 / secondBody.mass)
        self.impulse = collisionImpulse
    }

    convenience init?(firstBody: PhysicsBody, secondBody: PhysicsBody) {
        switch(firstBody, secondBody) {
        case let (firstBody as CirclePhysicsBody, secondBody as CirclePhysicsBody):
            self.init(firstBody: firstBody, secondBody: secondBody)
        case let (firstBody as EdgePhysicsBody, secondBody as CirclePhysicsBody):
            self.init(firstBody: firstBody, secondBody: secondBody)
        case let (firstBody as CirclePhysicsBody, secondBody as EdgePhysicsBody):
            self.init(firstBody: firstBody, secondBody: secondBody)
        case let (firstBody as RectanglePhysicsBody, secondBody as CirclePhysicsBody):
            self.init(firstBody: firstBody, secondBody: secondBody)
        case let (firstBody as CirclePhysicsBody, secondBody as RectanglePhysicsBody):
            self.init(firstBody: firstBody, secondBody: secondBody)
        case (_, _):
            return nil
        }
    }

    convenience init?(firstBody: CirclePhysicsBody, secondBody: CirclePhysicsBody) {
        let normal: CGVector = (secondBody.position - firstBody.position).normalized()
        self.init(firstBody: firstBody, secondBody: secondBody, contactNormal: normal)
    }

    convenience init?(firstBody: EdgePhysicsBody, secondBody: CirclePhysicsBody) {
        let edge = CGVector.vector(fromPoint: firstBody.destination) - CGVector.vector(fromPoint: firstBody.source)
        let normal: CGVector = edge.otherNormal().normalized()
        self.init(firstBody: firstBody, secondBody: secondBody, contactNormal: normal)
    }

    convenience init?(firstBody: CirclePhysicsBody, secondBody: EdgePhysicsBody) {
        let edge = CGVector.vector(fromPoint: secondBody.destination) - CGVector.vector(fromPoint: secondBody.source)
        let normal: CGVector = edge.normal().normalized()
        self.init(firstBody: firstBody, secondBody: secondBody, contactNormal: normal)
    }

    convenience init?(firstBody: CirclePhysicsBody, secondBody: RectanglePhysicsBody) {
        let closestEdgeVector = CGVector.getClosestEdgeVector(rectangleBody: secondBody, circleBody: firstBody)
        let normal: CGVector = closestEdgeVector?.otherNormal().normalized() ?? -(firstBody.velocity.normalized())
        self.init(firstBody: firstBody, secondBody: secondBody, contactNormal: normal)
    }

    convenience init?(firstBody: RectanglePhysicsBody, secondBody: CirclePhysicsBody) {
        let closestEdgeVector = CGVector.getClosestEdgeVector(rectangleBody: firstBody, circleBody: secondBody)
        let normal: CGVector = closestEdgeVector?.normal().normalized() ?? -(secondBody.velocity.normalized())
        self.init(firstBody: firstBody, secondBody: secondBody, contactNormal: normal)
    }

    func resolveCollision(resolvers: [CollisionResolver]) {
        resolvers.forEach({ $0.resolve(collision: self) })
    }
}
