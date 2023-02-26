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
    let gameplayArea: CGRect

    private(set) var gameboard: Gameboard
    private(set) var launchBall = Ball()
    private(set) var extraBalls: [Ball] = []
    private(set) var bucket = Bucket()

    var allBalls: [Ball] {
        Array([[launchBall], extraBalls].joined())
    }

    private(set) var gameStats = GameStats(
        remainingBallsCount: GameEngine.defaultBallCount, timeRemaining: TimeInterval.infinity, score: 0)
    private(set) var removedHitPegsCount: Int = 0

    var currentlyHitPegsCount: Int {
        gameboard.pegs.filter({ $0.isHit }).count
    }
    var remainingOrangePegsCount: Int {
        gameboard.pegs.filter({ $0.type == .orange }).count
    }

    private var timer: Timer?

    private(set) var gameMode: GameMode!
    private(set) var powerup: Powerup!
    var isSpookyBallActivated = false
    var isSpicyPegHit = false

    var areAllScoresCalculated: Bool {
        gameboard.pegs.allSatisfy({ !$0.isHit })
    }

    var hasLaunchEnded: Bool {
        areBallsOutsideGameplayArea && !isSpookyBallActivated
    }

    private var centrePoint: CGPoint {
        CGPoint(x: gameplayArea.midX, y: gameplayArea.midY)
    }

    var areHitPegsRemoved: Bool {
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
        spiceUpPegs()
        setupPhysicsBodies()
    }

    @objc func updateGame() {
        handleGameLogic()
        physicsWorld.updateWorld()
        rendererDelegate?.render()
    }

    func updateBallCount(_ incrementValue: Int) {
        gameStats.remainingBallsCount += incrementValue
        if gameStats.remainingBallsCount < 0 {
            gameStats.remainingBallsCount = 0
        }
    }

    func updateTimeLeft(_ incrementValue: TimeInterval) {
        gameStats.timeRemaining += incrementValue
        if gameStats.timeRemaining < 0 {
            gameStats.timeRemaining = 0
        }
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

    private func handleGameLogic() {
        moveBucket()
        removeBlockingObjects()
        handleBallOutsideGameplayArea()
        handleBallEnteredBucket()
        handlePowerups()
        handleSpicyPegs()
    }

    private func removeBlockingObjects() {
        allBalls.forEach({ removeBlockingObjectsWhenBallStuck(ball: $0) })
    }

    private func handleBallOutsideGameplayArea() {
        if isSpookyBallActivated {
            teleportSpookyBall()
        }
        isSpicyPegHit = false
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
                removedHitPegsCount += 1
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
        gameboard.pegs.filter({ $0.isHit }).forEach({ removePeg(peg: $0) })
    }

    func removePeg(peg: Peg) {
        physicsWorld.removePhysicsBody(physicsBody: peg.physicsBody)
        gameboard.deletePeg(deletedPeg: peg)
        removedHitPegsCount += 1
        gameStats.score += PegType.pegScoreMapping[peg.type] ?? 0
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

    func isObjectOutsideGameplayArea(objectFrame: CGRect) -> Bool {
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

    private func spiceUpPegs() {
        if gameboard.pegs.count >= 10 {
            let pegToReplace = gameboard.pegs.first(where: { $0.type != .orange })
            replacePegWithSpicyPeg(type: .zombie, pegToReplace: pegToReplace)
        }
        if gameboard.pegs.count >= 20 {
            let pegToReplace = gameboard.pegs.filter({ $0.type != .orange }).suffix(1).first
            replacePegWithSpicyPeg(type: .inverter, pegToReplace: pegToReplace)
        }
    }

    private func replacePegWithSpicyPeg(type: PegType, pegToReplace: Peg?) {
        guard let pegToReplace = pegToReplace else {
            return
        }
        let newSpicyPeg = Peg(location: pegToReplace.location, type: type,
                              radius: pegToReplace.radius, angle: pegToReplace.angle)
        _ = gameboard.replacePeg(oldPeg: pegToReplace, newPeg: newSpicyPeg)
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

    func setupExtraBall(location: CGPoint) {
        let extraBall = Ball(location: location)
        self.extraBalls.append(extraBall)
        physicsWorld.addPhysicsBody(physicsBody: extraBall.physicsBody)
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
