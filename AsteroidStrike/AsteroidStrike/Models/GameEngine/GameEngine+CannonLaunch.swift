//
//  GameEngine+CannonLaunch.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 26/2/23.
//

import CoreGraphics
import Foundation

extension GameEngine {
    func launchCannon(from location: CGPoint, atAngle launchAngle: CGFloat) {
        guard isCannonLaunchable() else {
            return
        }
        let launchSpeed: CGFloat = GameEngine.defaultLaunchSpeed
        let launchVelocity = CGVector(dx: -sin(launchAngle), dy: cos(launchAngle)) * launchSpeed
        launchBall.physicsBody.velocity = CGVector.zero
        launchBall.physicsBody.position = CGVector(dx: location.x, dy: location.y)
        launchBall.physicsBody.isDynamic = true
        launchBall.physicsBody.applyImpulse(impulse: launchVelocity * launchBall.physicsBody.mass)
        updateBallCount(-1)
    }

    private func isCannonLaunchable() -> Bool {
        return !gameMode.isGameOver() && hasLaunchEnded && areHitPegsRemoved
        && (rendererDelegate?.isRendererAnimationComplete() != false)
    }
}
