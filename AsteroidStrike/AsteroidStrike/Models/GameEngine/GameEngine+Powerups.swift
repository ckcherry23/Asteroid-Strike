//
//  GameEngine+Powerups.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 26/2/23.
//

import CoreGraphics

extension GameEngine {
    func teleportSpookyBall() {
        allBalls.forEach({
            if isObjectOutsideGameplayArea(objectFrame: $0.frame) {
                $0.resetPosition(to: CGPoint(x: $0.location.x, y: gameplayArea.minY))
                isSpookyBallActivated = false
                powerup.deactivateUsedPowerups(powerups: powerup.getPowerupsToDeactivate())
            }
        })
    }

    func destroyNearbyPegs(radius: CGFloat) {
        let powerupsToDeactivate = powerup.getPowerupsToDeactivate()
        powerupsToDeactivate.forEach({ powerup in
            physicsWorld.getBodiesNear(body: powerup.physicsBody, radius: radius)
            .forEach({
                $0.hitCounter += 1
            })
        })
        powerup.deactivateUsedPowerups(powerups: powerupsToDeactivate)
    }
}
