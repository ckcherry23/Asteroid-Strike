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
    static let defaultBallCount: Int = 10

    let physicsWorld = PhysicsWorld()
    var rendererDelegate: RendererDelegate?
    private(set) var gameMode: GameMode!

    let gameplayArea: CGRect
    var gameboard: Gameboard
    var launchBall: Ball = Ball()
    var extraBalls: [Ball] = []

    var allBalls: [Ball] {
        Array([[launchBall], extraBalls].joined())
    }

    var remainingBallsCount: Int = GameEngine.defaultBallCount
    var timeRemaining: TimeInterval = TimeInterval.infinity // TODO: Timer
    var hitPegsCount: Int = 0
    var remainingOrangePegsCount: Int {
        gameboard.pegs.filter({ $0.type == .orange }).count
    }
    var score: Int = 0

    var hasLaunchEnded: Bool {
        areBallsOutsideGameplayArea
    }

    private var centrePoint: CGPoint {
        CGPoint(x: gameplayArea.midX, y: gameplayArea.midY)
    }

    private var areHitPegsRemoved: Bool {
        gameboard.pegs.allSatisfy({ !$0.isHit })
    }

    private var areBallsOutsideGameplayArea: Bool {
        allBalls.allSatisfy({ !gameplayArea.intersects($0.frame) })
    }

    init(gameboard: Gameboard, gameplayArea: CGRect, rendererDelegate: RendererDelegate? = nil) {
        self.gameboard = gameboard
        self.gameplayArea = gameplayArea
        self.rendererDelegate = rendererDelegate
        self.gameMode = ClassicMode(gameEngine: self)
        setupPhysicsBodies()
    }

    @objc func updateGame() {
        removeBlockingObjects()
        removeHitPegsOnLaunchEnd()
        physicsWorld.updateWorld()
        rendererDelegate?.render()
    }

    func setGameMode(gameMode: GameMode) {
        self.gameMode = gameMode
        setupGameState()
    }

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
        remainingBallsCount -= 1
    }

    private func removeBlockingObjects() {
        allBalls.forEach({ removeBlockingObjectsWhenBallStuck(ball: $0) })
    }

    private func removeBlockingObjectsWhenBallStuck(ball: Ball) {
        guard ball.isStuck() else {
            return
        }
        physicsWorld.getBodiesInContact(with: ball.physicsBody).forEach({ physicsBody in
            if let pegToBeDeleted = gameboard.pegs.first(where: { peg in peg.physicsBody === physicsBody }) {
                gameboard.deletePeg(deletedPeg: pegToBeDeleted)
                physicsWorld.removePhysicsBody(physicsBody: physicsBody)
                hitPegsCount += 1
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
            hitPegsCount += 1
        })
    }

    private func isCannonLaunchable() -> Bool {
        return areBallsOutsideGameplayArea && areHitPegsRemoved
        && !gameMode.isGameOver()
        && (rendererDelegate?.isRendererAnimationComplete() != false)
    }

    private func setupGameState() {
        remainingBallsCount = gameMode.totalBallsCount
        timeRemaining = gameMode.timeLimit
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
        self.launchBall = Ball(location: CGPoint(x: centrePoint.x,
                                                 y: gameplayArea.maxY + GameEngine.defaultBallHeightOffset))
        physicsWorld.addPhysicsBody(phyicsBody: launchBall.physicsBody)
    }

    private func setupPegs() {
        gameboard.pegs.forEach({ physicsWorld.addPhysicsBody(phyicsBody: $0.physicsBody) })
    }

    private func setupBlocks() {
        gameboard.blocks.forEach({ physicsWorld.addPhysicsBody(phyicsBody: $0.physicsBody) })
    }
}
