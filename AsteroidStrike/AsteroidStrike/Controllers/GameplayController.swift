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
    private var ballView: BallView!
    private var pegViews: [PegView] = []
    private var glowingPegViews: [PegView] = []
    private var displayLink: CADisplayLink!
    private var isDisappearAnimationComplete = true

    private var gameEngine: GameEngine!

    override func viewDidLayoutSubviews() {
        setupGameEngine()
        addGameplayElements()
        addGameboardElements()
        setupDisplayRefreshLoop()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tearDownDisplayRefreshLoop()
    }

    private func setupGameEngine() {
        let gameboard = Gameboard.getDefaultGameboard(of: gameplayArea.bounds.size)
        gameEngine = GameEngine(gameboard: gameboard, gameplayArea: gameplayArea.bounds, rendererDelegate: self)
    }

    private func addGameplayElements() {
        addCannonToGameplayArea()
        addBallToGameplayArea()
    }

    private func addCannonToGameplayArea() {
        gameplayArea.addSubview(cannonView)
    }

    private func addBallToGameplayArea() {
        ballView = BallView(frame: gameEngine.ball.frame)
        gameplayArea.addSubview(ballView)
    }

    private let pegColorToViewMapping: [PegColor: (Peg) -> (PegView) ] = [
        .blue: { (peg) in BluePegView(at: peg.location, radius: peg.radius) },
        .orange: { (peg) in OrangePegView(at: peg.location, radius: peg.radius) }
    ]

    private func addGameboardElements() {
        for peg in gameEngine.gameboard.pegs {
            guard let createPegViewFromPeg = pegColorToViewMapping[peg.color] else {
                continue
            }
            addPegToView(pegView: createPegViewFromPeg(peg))
        }
    }

    private func addPegToView(pegView: PegView) {
        gameplayArea.addSubview(pegView)
        pegViews.append(pegView)
    }

    private func updateBall() {
        ballView.center = gameEngine.ball.location
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

    private func fadeOutRemovedPegs() {
        guard gameEngine.ball.isStuck() else {
            return
        }
        let removedPegs = pegViews.filter({ pegView in
            !gameEngine.gameboard.pegs.map({ $0.location }).contains(pegView.center)})
        fadeOutViews(views: removedPegs)
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
        pegViews.first(where: { $0.center == peg.location })
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
        updateBall()
        lightUpHitPegs()
        fadeOutRemovedPegs()
        fadeOutLitPegsOnLaunchEnd()
    }

    func isRendererAnimationComplete() -> Bool {
        isDisappearAnimationComplete
    }
}

protocol RendererDelegate: AnyObject {
    func render()
    func isRendererAnimationComplete() -> Bool
}
