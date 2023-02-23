//
//  Ball.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 5/2/23.
//

import Foundation

class Ball {
    private static let defaultRadius: CGFloat = 25
    private static let stuckTimeLimit: TimeInterval = 3
    private static let minDisplacementForMovement: CGFloat = 1

    private(set) var radius: CGFloat = Ball.defaultRadius

    private(set) var physicsBody: PhysicsBody

    private var timeElapsedSinceBallMovement: TimeInterval = 0.0
    private var lastRecordedTime: Date = Date()
    private var lastRecordedLocation: CGPoint = CGPoint.zero

    var frame: CGRect {
        physicsBody.boundingBox
    }

    var location: CGPoint {
        CGPoint(x: physicsBody.position.dx, y: physicsBody.position.dy)
    }

    init(location: CGPoint = CGPoint(), radius: CGFloat = Ball.defaultRadius) {
        self.radius = radius
        self.physicsBody = CirclePhysicsBody(radius: radius, center: location)
    }

    func isStuck() -> Bool {
        guard location.distanceFrom(other: lastRecordedLocation) < Ball.minDisplacementForMovement else {
            lastRecordedLocation = location
            timeElapsedSinceBallMovement = 0
            return false
        }
        let timeElapsed = lastRecordedTime.timeIntervalSinceNow.magnitude
        timeElapsedSinceBallMovement += timeElapsed
        lastRecordedTime = Date()
        lastRecordedLocation = location
        return timeElapsedSinceBallMovement > Ball.stuckTimeLimit
    }
}
