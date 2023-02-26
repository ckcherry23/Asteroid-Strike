//
//  PhysicsBody.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 4/2/23.
//

import Foundation
import CoreGraphics

class PhysicsBody {
    private static var defaultMass: CGFloat = 1
    private static var defaultRestitution: CGFloat = 0.9

    var isDynamic = true

    var isAffectedByGravity = true {
        didSet(oldValue) {
            if isAffectedByGravity != oldValue {
                updateGravityEffects()
            }
        }
    }

    var mass: CGFloat = PhysicsBody.defaultMass

    var position: CGVector {
        get {
            CGVector(dx: hitBox.boundingBox.midX, dy: hitBox.boundingBox.midY)
        }
        set(newPosition) {
            hitBox = hitBox.translate(from: position, to: newPosition)
        }
    }

    var collisionBitmask: UInt32 = 0xFFFFFFFF
    var categoryBitmask: UInt32 = 0xFFFFFFFF

    private(set) var angle: CGFloat

    private var force = CGVector.zero

    private var acceleration: CGVector {
        force / mass
    }

    private var gravitationalForce: CGVector {
        PhysicsWorld.gravity * mass
    }

    var velocity = CGVector.zero

    var isResting: Bool {
        velocity == CGVector.zero
    }

    var restitution: CGFloat = PhysicsBody.defaultRestitution

    private var hitBox: CGPath

    var boundingBox: CGRect {
        hitBox.boundingBox
    }

    var hitCounter: Int = 0

    fileprivate init(radius: CGFloat, center: CGPoint, angle: CGFloat = 0.0) {
        self.angle = angle
        hitBox = CGPath(ellipseIn: CGRect.boundingBoxForCircle(center: center, radius: radius),
                        transform: nil)
        addGravityEffects()
    }

    fileprivate init(source: CGPoint, destination: CGPoint, angle: CGFloat = 0.0) {
        self.angle = angle
        let path = CGMutablePath()
        path.move(to: source)
        path.addLine(to: destination)
        path.closeSubpath()
        hitBox = path.copy(strokingWithWidth: 1, lineCap: .square, lineJoin: .round, miterLimit: 1)
        addGravityEffects()
    }

    fileprivate init(rect: CGRect, angle: CGFloat) {
        self.angle = angle
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: angle)
            .translatedBy(x: -center.x, y: -center.y)
        hitBox = CGPath(rect: rect, transform: &transform)
        addGravityEffects()
    }

    func contains(point: CGPoint) -> Bool {
        hitBox.contains(point)
    }
}

extension PhysicsBody {
    func updateBody(timeInterval: TimeInterval) {
        guard isDynamic else {
            return
        }
        updatePosition(timeInterval: timeInterval)
    }

    private func addGravityEffects() {
        if isAffectedByGravity {
            applyForce(newForce: gravitationalForce)
        }
    }

    private func updateGravityEffects() {
        if isAffectedByGravity {
            applyForce(newForce: gravitationalForce)
        } else {
            applyForce(newForce: -gravitationalForce)
        }
    }
}

extension PhysicsBody: Movable {
    func applyForce(newForce: CGVector) {
        guard isDynamic else {
            return
        }
        force += newForce
    }

    func applyImpulse(impulse: CGVector) {
        guard isDynamic else {
            return
        }
        velocity += impulse * (1 / mass)
    }

    private func updatePosition(timeInterval: TimeInterval) {
        guard isDynamic else {
            return
        }
        velocity += acceleration * timeInterval
        position += velocity * timeInterval
    }
}

extension PhysicsBody: Collidable {
    func detectCollision(other: PhysicsBody) -> PhysicsCollision? {
        guard self !== other && self.isIntersecting(other: other) else {
            return nil
        }
        hitCounter += 1
        other.hitCounter += 1
        return PhysicsCollision(firstBody: self, secondBody: other)
    }

    func isCollidableWith(other: PhysicsBody) -> Bool {
        (self.collisionBitmask & other.categoryBitmask) != 0
    }

    func isIntersecting(other: PhysicsBody) -> Bool {
        hitBox.intersects(other.hitBox)
    }
}

class CirclePhysicsBody: PhysicsBody {
    override init(radius: CGFloat, center: CGPoint, angle: CGFloat = 0.0) {
        super.init(radius: radius, center: center, angle: angle)
    }
}

class EdgePhysicsBody: PhysicsBody {
    var source: CGPoint
    var destination: CGPoint
    override init(source: CGPoint, destination: CGPoint, angle: CGFloat = 0.0) {
        self.source = source
        self.destination = destination
        super.init(source: source, destination: destination, angle: angle)
    }
}

class RectanglePhysicsBody: PhysicsBody {
    var rect: CGRect
    override init(rect: CGRect, angle: CGFloat = 0.0) {
        self.rect = rect
        super.init(rect: rect, angle: angle)
    }
}
