//
//  GameplayController.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 5/2/23.
//

import UIKit

class GameplayController: UIViewController {
    private static let minFrameRate: Float = 10
    private static let maxFrameRate: Float = 120
    private static let pegViewAnimationDuration = 0.5
    private static let pegViewAnimationDelay = 0.3

    @IBOutlet weak var gameplayArea: UIImageView!
    @IBOutlet weak var cannonView: CannonView!
    @IBOutlet weak var bucketView: UIImageView!

    @IBOutlet weak var remainingBallsCountDisplay: UILabel!
    @IBOutlet weak var timerDisplay: UILabel!
    @IBOutlet weak var remainingOrangePegsCountDisplay: UILabel!
    @IBOutlet weak var scoreDisplay: UILabel!

    private var ballViews: [BallView] = []
    private var pegViews: [PegView] = []
    private var blockViews: [BlockView] = []
    private var glowingPegViews: [PegView] = []

    var canvasObjects: [any CanvasObject] {
        let canvasObjectsArray: [[any CanvasObject]] = [pegViews, blockViews]
        return Array(canvasObjectsArray.joined())
    }

    private var displayLink: CADisplayLink!
    private var isDisappearAnimationComplete = true
    private var isGameboardUpsideDown = false

    private(set) var gameEngine: GameEngine!
    var gameboardDelegate: GameboardDelegate?

    private var isFirstLoad = true

    override func viewDidLayoutSubviews() {
        guard isFirstLoad else {
            return
        }
        setupGameEngine()
        addGameplayElements()
        addGameboardElements()
        setupDisplayRefreshLoop()
        showGameModeModal()
        isFirstLoad = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tearDownDisplayRefreshLoop()
    }

    private func setupGameEngine() {
        let gameboard = gameboardDelegate?.getGameBoard() ?? Gameboard.getDefaultGameboard(of: gameplayArea.bounds.size)
        gameEngine = GameEngine(gameboard: gameboard, gameplayArea: gameplayArea.bounds, rendererDelegate: self)
    }

    private func addGameplayElements() {
        addPersistentObjectsToGameplayArea()
        addBallToGameplayArea()
    }

    private func addPersistentObjectsToGameplayArea() {
        gameplayArea.addSubview(cannonView)
        gameplayArea.addSubview(bucketView)
    }

    private func addBallToGameplayArea() {
        let ballView = BallView(frame: gameEngine.launchBall.frame)
        ballViews.append(ballView)
        gameplayArea.addSubview(ballView)
    }

    private func createBlockViewFromBlock(block: Block) -> BlockView {
        BlockView(at: block.location, size: block.size, angle: block.angle)
    }

    private func addGameboardElements() {
        addPegs()
        addBlocks()
    }

    private func addPegs() {
        for peg in gameEngine.gameboard.pegs {
            guard let createPegViewFromPeg = PegType.pegViewMapping[peg.type] else {
                continue
            }
            addPegToView(pegView: createPegViewFromPeg(peg))
        }
    }

    private func addBlocks() {
        for block in gameEngine.gameboard.blocks {
            addBlockToView(blockView: createBlockViewFromBlock(block: block))
        }
    }

    private func addPegToView(pegView: PegView) {
        gameplayArea.addSubview(pegView)
        pegViews.append(pegView)
    }

    private func addBlockToView(blockView: BlockView) {
        gameplayArea.addSubview(blockView)
        blockViews.append(blockView)
    }

    private func updateMovingObjects() {
        updateBalls()
        updateBucket()
    }

    private func updateBalls() {
        for (index, ball) in gameEngine.allBalls.enumerated() {
            if index >= ballViews.count {
                let ballView = BallView(frame: ball.frame)
                ballViews.append(ballView)
                gameplayArea.addSubview(ballView)
            }
            if !isGameboardUpsideDown {
                ballViews[index].center = ball.location
            } else {
                ballViews[index].center = ball.location.rotatedUpsideDown(frame: gameplayArea.frame)
            }
        }
    }

    private func updateBucket() {
        bucketView.center = gameEngine.bucket.location
    }

    private func lightUpHitPegs() {
        glowingPegViews = []
        gameEngine.gameboard.pegs.filter({ $0.isHit }).forEach({
            guard let pegView = getPegViewForPeg($0) else {
                return
            }
            pegView.isHit = true
            glowingPegViews.append(pegView)
        })
    }

    private func fadeOutRemovedObjects() {
        let removedPegs = pegViews.filter({ pegView in
            !gameEngine.gameboard.pegs.compactMap({ $0.location }).contains(pegView.location)
        })
        let removedBlocks = blockViews.filter({ blockView in
            !gameEngine.gameboard.blocks.compactMap({ $0.location }).contains(blockView.location)
        })

        fadeOutViews(views: removedPegs)
        fadeOutViews(views: removedBlocks)
    }

    private func fadeOutLitPegsOnLaunchEnd() {
        guard gameEngine.hasLaunchEnded else {
            return
        }
        let animationDelay = gameEngine.gameMode.isTimerNeeded ? 0 : GameplayController.pegViewAnimationDelay
        fadeOutViews(views: glowingPegViews, delay: animationDelay)
    }

    private func fadeOutViews(views: [UIView], delay: TimeInterval = 0.0) {
        for (index, view) in views.enumerated() {
            let animationDelay = delay * Double(index)
            if animationDelay > 0 {
                isDisappearAnimationComplete = false
            }
            UIView.animate(withDuration: GameplayController.pegViewAnimationDuration, delay: animationDelay,
                           animations: { view.alpha = 0.0 }, completion: { _ in
                if index == views.count - 1 {
                    self.isDisappearAnimationComplete = true
                }
            })
        }
    }

    private func getPegViewForPeg(_ peg: Peg) -> PegView? {
        pegViews.first(where: { $0.location == peg.location })
    }

    func setPowerupMode(powerup: PowerupMode) {
        gameEngine.setPowerup(powerup: powerup)
    }

    private func updateGameStats() {
        if gameEngine.gameMode.isTimerNeeded {
            timerDisplay.superview?.isHidden = false
            remainingBallsCountDisplay.superview?.isHidden = true
            timerDisplay.text = String(gameEngine.gameStats.timeRemaining)
        } else {
            timerDisplay.superview?.isHidden = true
            remainingBallsCountDisplay.superview?.isHidden = false
        }

        if gameEngine.gameMode.hasTargetScore {
            remainingOrangePegsCountDisplay.superview?.isHidden = true
            scoreDisplay.text = String(gameEngine.gameStats.score) + "/" +
            String(gameEngine.gameMode.targetScore)
        } else {
            remainingOrangePegsCountDisplay.superview?.isHidden = false
            remainingOrangePegsCountDisplay.text = String(gameEngine.remainingOrangePegsCount)
            scoreDisplay.text = String(gameEngine.gameStats.score)
        }

        remainingBallsCountDisplay.text = String(gameEngine.gameStats.remainingBallsCount)

    }

    private func setupDisplayRefreshLoop() {
        displayLink = CADisplayLink(target: gameEngine!, selector: #selector(gameEngine.updateGame))
        displayLink.add(to: .current, forMode: .default)
        displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: GameplayController.minFrameRate,
                                                               maximum: GameplayController.maxFrameRate,
                                                               __preferred: gameEngine.physicsWorld.frameRate)
    }

    private func tearDownDisplayRefreshLoop() {
        displayLink.remove(from: .current, forMode: .default)
    }

    @IBAction func onPanGameplayArea(_ gestureRecognizer: UIPanGestureRecognizer) {
        let panLocation: CGPoint = gestureRecognizer.location(in: gameplayArea)
        let angleOfRotation: CGFloat = getAngleOfRotation(from: panLocation)
        cannonView.rotate(by: angleOfRotation)
    }

    @IBAction func onTapGameplayArea(_ gestureRecognizer: UITapGestureRecognizer) {
        let launchAngle: CGFloat = atan2(cannonView.transform.b, cannonView.transform.a)
        gameEngine.launchCannon(from: cannonView.center, atAngle: launchAngle)
    }

    private func getAngleOfRotation(from location: CGPoint) -> CGFloat {
        let oppositeSide = location.x - cannonView.center.x
        let adjacentSide = cannonView.center.y - location.y
        guard adjacentSide <= 0 else {
            if oppositeSide > 0 {
                return -(.pi / 2)
            } else {
                return .pi / 2
            }
        }
        return atan(oppositeSide / adjacentSide)
    }
}

extension GameplayController: RendererDelegate {
    func render() {
        updateMovingObjects()
        lightUpHitPegs()
        fadeOutRemovedObjects()
        fadeOutLitPegsOnLaunchEnd()
        updateGameStats()
        showGameMessages()
    }

    func isRendererAnimationComplete() -> Bool {
        isDisappearAnimationComplete
    }

    func toggleGameboardOrientation() {
        isGameboardUpsideDown = !isGameboardUpsideDown
        canvasObjects.forEach({
            $0.center = $0.center.rotatedUpsideDown(frame: gameplayArea.frame)
        })
    }

    private func showGameMessages() {
        if gameEngine.gameMode.isGameOver() {
            displayLink.isPaused = true
            onGameOver(hasWon: gameEngine.gameMode.hasWon)
        }
    }
}
