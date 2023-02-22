//
//  GameEngine.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 5/2/23.
//

import Foundation
import CoreGraphics

class GameEngine {
    static let defaultBallHeightOffset: CGFloat = 200
    static let defaultLaunchSpeed: CGFloat = 500

    let physicsWorld = PhysicsWorld()
    var rendererDelegate: RendererDelegate?

    let gameplayArea: CGRect
    var gameboard: Gameboard
    var ball: Ball = Ball()

    var centrePoint: CGPoint {
        CGPoint(x: gameplayArea.midX, y: gameplayArea.midY)
    }

    var hasLaunchEnded: Bool {
        isBallOutsideGameplayArea
    }

    private var areHitPegsRemoved: Bool {
        gameboard.pegs.allSatisfy({ !$0.isHit })
    }

    private var isBallOutsideGameplayArea: Bool {
        !gameplayArea.intersects(ball.frame)
    }

    init(gameboard: Gameboard, gameplayArea: CGRect, rendererDelegate: RendererDelegate? = nil) {
        self.gameboard = gameboard
        self.gameplayArea = gameplayArea
        self.rendererDelegate = rendererDelegate
        setupPhysicsBodies()
    }

    @objc func updateGame() {
        removeBlockingObjectsWhenBallStuck()
        removeHitPegsOnLaunchEnd()
        physicsWorld.updateWorld()
        rendererDelegate?.render()
    }

    func launchCannon(from location: CGPoint, atAngle launchAngle: CGFloat) {
        guard isCannonLaunchable() else {
            return
        }
        let launchSpeed: CGFloat = GameEngine.defaultLaunchSpeed
        let launchVelocity = CGVector(dx: -sin(launchAngle), dy: cos(launchAngle)) * launchSpeed
        ball.physicsBody.velocity = CGVector.zero
        ball.physicsBody.position = CGVector(dx: location.x, dy: location.y)
        ball.physicsBody.isDynamic = true
        ball.physicsBody.applyImpulse(impulse: launchVelocity * ball.physicsBody.mass)
    }

    private func removeBlockingObjectsWhenBallStuck() {
        guard ball.isStuck() else {
            return
        }
        physicsWorld.getBodiesInContact(with: ball.physicsBody).forEach({ physicsBody in
            if let pegToBeDeleted = gameboard.pegs.first(where: { peg in peg.physicsBody === physicsBody }) {
                gameboard.deletePeg(deletedPeg: pegToBeDeleted)
                physicsWorld.removePhysicsBody(physicsBody: physicsBody)
            } else if let blockToBeDeleted = gameboard.blocks.first(where: { block in
                block.physicsBody === physicsBody }) {
                gameboard.deleteBlock(deletedBlock: blockToBeDeleted)
                physicsWorld.removePhysicsBody(physicsBody: physicsBody)
            }
        })
    }

    private func removeHitPegsOnLaunchEnd() {
        guard hasLaunchEnded else {
            return
        }
        gameboard.pegs.filter({ $0.isHit }).forEach({
            physicsWorld.removePhysicsBody(physicsBody: $0.physicsBody)
            gameboard.deletePeg(deletedPeg: $0)
        })
    }

    private func isCannonLaunchable() -> Bool {
        return isBallOutsideGameplayArea && areHitPegsRemoved
        && ((rendererDelegate?.isRendererAnimationComplete()) != false)
    }

    private func setupPhysicsBodies() {
        setupWalls()
        setupBall()
        setupPegs()
        setupBlocks()
    }

    private func setupWalls() {
        let edges = gameplayArea.getEdges()
        let wallEdges = [edges.top, edges.left, edges.right]
        wallEdges.forEach({ setupWall(wall: $0) })
    }

    private func setupWall(wall: RectangleEdges.Edge) {
        let wall = Wall(edge: wall)
        physicsWorld.addPhysicsBody(phyicsBody: wall.physicsBody)
    }

    private func setupBall() {
        self.ball = Ball(location: CGPoint(x: centrePoint.x, y: gameplayArea.maxY + GameEngine.defaultBallHeightOffset))
        physicsWorld.addPhysicsBody(phyicsBody: ball.physicsBody)
    }

    private func setupPegs() {
        gameboard.pegs.forEach({ physicsWorld.addPhysicsBody(phyicsBody: $0.physicsBody) })
    }

    private func setupBlocks() {
        gameboard.blocks.forEach({ physicsWorld.addPhysicsBody(phyicsBody: $0.physicsBody) })
    }
}
