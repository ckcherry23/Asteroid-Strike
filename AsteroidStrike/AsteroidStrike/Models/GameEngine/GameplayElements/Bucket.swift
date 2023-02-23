//
//  Bucket.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 23/2/23.
//

import CoreGraphics

class Bucket {
    private static let defaultSize = CGSize(width: 120, height: 60)
    private static let defaultSpeed = CGVector(dx: 200, dy: 0)

    private(set) var initialLocation: CGPoint
    private(set) var size: CGSize = Bucket.defaultSize
    private(set) var leftEdge: EdgePhysicsBody
    private(set) var rightEdge: EdgePhysicsBody
    var physicsBodies: [EdgePhysicsBody] {
        [leftEdge, rightEdge]
    }

    var location: CGPoint {
        let midX = (leftEdge.position.dx + rightEdge.position.dx) / 2
        return CGPoint(x: midX, y: initialLocation.y)
    }

    var opening: CGRect {
        let openingSize = CGSize(width: 120, height: 10)
        return CGRect(origin: CGPoint(x: leftEdge.position.dx, y: leftEdge.source.y),
               size: openingSize)
    }

    init(center: CGPoint = CGPoint()) {
        self.initialLocation = center
        let corners = CGRect.centeredRectangle(center: center, size: size).getCorners()

        self.leftEdge = EdgePhysicsBody(source: corners.topLeft, destination: corners.bottomLeft)
        leftEdge.isAffectedByGravity = false
        leftEdge.collisionBitmask = PhysicsBodyCategory.none

        self.rightEdge = EdgePhysicsBody(source: corners.topRight, destination: corners.bottomRight)
        rightEdge.isAffectedByGravity = false
        rightEdge.collisionBitmask = PhysicsBodyCategory.none

        move()
    }

    func oscillateBetweenWalls(gameplayArea: CGRect) {
        if isAtLeftBoundary(of: gameplayArea) || isAtRightBoundary(of: gameplayArea) {
            reverseDirection()
        }
    }

    private func move() {
        physicsBodies.forEach({ $0.applyImpulse(impulse: Bucket.defaultSpeed)})
    }

    private func isAtLeftBoundary(of rect: CGRect) -> Bool {
        leftEdge.position.dx <= rect.minX
    }

    private func isAtRightBoundary(of rect: CGRect) -> Bool {
        rightEdge.position.dx >= rect.maxX
    }

    private func reverseDirection() {
        physicsBodies.forEach({ $0.velocity = -$0.velocity })
    }
}
