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

    private let gameplayArea: CGRect
    private(set) var gameboard: Gameboard
    private(set) var launchBall: Ball = Ball()
    private(set) var extraBalls: [Ball] = []
    private(set) var bucket: Bucket = Bucket()

    var allBalls: [Ball] {
        Array([[launchBall], extraBalls].joined())
    }

    private(set) var gameStats: GameStats = GameStats(
        remainingBallsCount: GameEngine.defaultBallCount, timeRemaining: TimeInterval.infinity, score: 0)
    private(set) var hitPegsCount: Int = 0
    var remainingOrangePegsCount: Int {
        gameboard.pegs.filter({ $0.type == .orange }).count
    }
    private var timer: Timer?

    private(set) var gameMode: GameMode!
    private(set) var powerup: Powerup!
    var isSpookyBallActivated: Bool = false

    var areAllScoresCalculated: Bool {
        gameboard.pegs.allSatisfy({ !$0.isHit })
    }

    var hasLaunchEnded: Bool {
        areBallsOutsideGameplayArea && !isSpookyBallActivated
    }

    private var centrePoint: CGPoint {
        CGPoint(x: gameplayArea.midX, y: gameplayArea.midY)
    }

    private var areHitPegsRemoved: Bool {
        gameboard.pegs.allSatisfy({ !$0.isHit })
    }

    private var areBallsOutsideGameplayArea: Bool {
        allBalls.allSatisfy({ isObjectOutsideGameplayArea(objectFrame: $0.frame) })
    }

    init(gameboard: Gameboard, gameplayArea: CGRect, rendererDelegate: RendererDelegate? = nil) {
        self.gameboard = gameboard
        self.gameplayArea = gameplayArea
        self.rendererDelegate = rendererDelegate
        self.gameMode = ClassicMode(gameEngine: self)
        self.powerup = KaboomPowerup(gameEngine: self)
        setupPhysicsBodies()
    }

    @objc func updateGame() {
        handleGameLogic()
        physicsWorld.updateWorld()
        rendererDelegate?.render()
    }

    func updateBallCount(_ incrementValue: Int) {
        gameStats.remainingBallsCount += incrementValue
    }

    func updateTimeLeft(_ incrementValue: TimeInterval) {
        gameStats.timeRemaining += incrementValue
    }

    func setGameMode(gameMode: GameModeType) {
        guard let gameModeInit = GameModeType.gameModeMapping[gameMode] else {
            return
        }
        self.gameMode = nil // to call deinit
        self.gameMode = gameModeInit(self)
        setupGameState()
    }

    func setPowerup(powerup: PowerupMode) {
        guard let powerupInit = PowerupMode.powerupMapping[powerup] else {
            return
        }
        self.powerup = nil // to call deinit
        self.powerup = powerupInit(self)
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
        gameStats.remainingBallsCount -= 1
    }

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
                $0.categoryBitmask = PhysicsBodyCategory.all
            })
        })
        powerup.deactivateUsedPowerups(powerups: powerupsToDeactivate)
    }

    private func handleGameLogic() {
        moveBucket()
        removeBlockingObjects()
        handleBallOutsideGameplayArea()
        handleBallEnteredBucket()
        handlePowerups()
    }

    private func removeBlockingObjects() {
        allBalls.forEach({ removeBlockingObjectsWhenBallStuck(ball: $0) })
    }

    private func handleBallOutsideGameplayArea() {
        if isSpookyBallActivated {
            teleportSpookyBall()
        }
        removeHitPegs(when: hasLaunchEnded)
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

    private func removeHitPegs(when removeCondition: Bool) {
        guard removeCondition else {
            return
        }
        gameboard.pegs.filter({ $0.isHit }).forEach({
            physicsWorld.removePhysicsBody(physicsBody: $0.physicsBody)
            gameboard.deletePeg(deletedPeg: $0)
            hitPegsCount += 1
            gameStats.score += PegType.pegScoreMapping[$0.type] ?? 0
        })
    }

    private func isCannonLaunchable() -> Bool {
        return !gameMode.isGameOver() && hasLaunchEnded && areHitPegsRemoved
        && (rendererDelegate?.isRendererAnimationComplete() != false)
    }

    private func handleBallEnteredBucket() {
        allBalls.forEach({
            guard $0.hasEntered(bucket: bucket) else {
                return
            }
            gameMode.onEnterBucket()
            $0.resetPosition(to: CGPoint(x: centrePoint.x,
                                         y: gameplayArea.maxY + GameEngine.defaultBallHeightOffset))
        })
    }

    private func handlePowerups() {
        powerup.handlePowerup()
    }

    private func isObjectOutsideGameplayArea(objectFrame: CGRect) -> Bool {
        !gameplayArea.intersects(objectFrame)
    }

    private func setupGameState() {
        if gameMode.isTimerNeeded {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimerExecution),
                                         userInfo: nil, repeats: true)
        }
        gameStats.remainingBallsCount = gameMode.totalBallsCount
        gameStats.timeRemaining = gameMode.timeLimit
    }

    @objc private func handleTimerExecution(_ timer: Timer) {
        if gameStats.timeRemaining > 0 {
            gameStats.timeRemaining -= 1
        } else {
            removeHitPegs(when: gameStats.timeRemaining <= 0)
            timer.invalidate()
        }
    }

    private func setupPhysicsBodies() {
        setupWalls()
        setupBall()
        setupBucket()
        setupPegs()
        setupBlocks()
    }

    private func moveBucket() {
        bucket.oscillateBetweenWalls(gameplayArea: gameplayArea)
    }

    private func setupWalls() {
        let edges = gameplayArea.getEdges()
        let wallEdges = [edges.top, edges.left, edges.right]
        wallEdges.forEach({ setupWall(wall: $0) })
    }

    private func setupWall(wall: RectangleEdges.Edge) {
        let wall = Wall(edge: wall)
        physicsWorld.addPhysicsBody(physicsBody: wall.physicsBody)
    }

    private func setupBall() {
        self.launchBall = Ball(location: CGPoint(x: centrePoint.x,
                                                 y: gameplayArea.maxY + GameEngine.defaultBallHeightOffset))
        physicsWorld.addPhysicsBody(physicsBody: launchBall.physicsBody)
    }

    private func setupBucket() {
        let bucketSize = CGSize(width: 120, height: 60)
        self.bucket = Bucket(center: CGPoint(x: centrePoint.x,
                                             y: gameplayArea.maxY - CGFloat(bucketSize.height / 2)))
        bucket.physicsBodies.forEach({ physicsWorld.addPhysicsBody(physicsBody: $0) })
    }

    private func setupPegs() {
        gameboard.pegs.forEach({ physicsWorld.addPhysicsBody(physicsBody: $0.physicsBody) })
    }

    private func setupBlocks() {
        gameboard.blocks.forEach({ physicsWorld.addPhysicsBody(physicsBody: $0.physicsBody) })
    }
}
