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
    private var ballView: BallView!
    private var pegViews: [PegView] = []
    private var blockViews: [BlockView] = []
    private var glowingPegViews: [PegView] = []
    private var displayLink: CADisplayLink!
    private var isDisappearAnimationComplete = true

    private var gameEngine: GameEngine!
    var gameboardDelegate: GameboardDelegate?

    override func viewDidLayoutSubviews() {
        setupGameEngine()
        addGameplayElements()
        addGameboardElements()
        setupDisplayRefreshLoop()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showGameModeModal()
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
        ballView = BallView(frame: gameEngine.launchBall.frame)
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
        updateBall()
        updateBucket()
    }

    private func updateBall() {
        ballView.center = gameEngine.launchBall.location
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
        guard gameEngine.launchBall.isStuck() else {
            return
        }
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
        fadeOutViews(views: glowingPegViews, delay: GameplayController.pegViewAnimationDelay)
    }

    private func fadeOutViews(views: [UIView], delay: TimeInterval = 0.0) {
        for (index, view) in views.enumerated() {
            isDisappearAnimationComplete = false
            let animationDelay = delay * Double(index)
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
        showGameMessages()
    }

    func isRendererAnimationComplete() -> Bool {
        isDisappearAnimationComplete
    }

    private func showGameMessages() {
        if gameEngine.gameMode.isGameOver() {
            displayLink.isPaused = true
            onGameOver(hasWon: gameEngine.gameMode.hasWon)
        }
    }
}

protocol RendererDelegate: AnyObject {
    func render()
    func isRendererAnimationComplete() -> Bool
}
