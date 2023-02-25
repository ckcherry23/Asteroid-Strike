//
//  GameplayController+Popups.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 23/2/23.
//

import UIKit

extension GameplayController {
    func showGameModeModal() {
        let title = "Choose your game mode"
        let message = "Decide what your powerups will do or if you're bored of classic mode, "
        + "pick from some brand new modes for the game!"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Classic Ka-Boom", style: .default, handler: { _ in
            self.gameEngine.setPowerup(powerup: .kaboom)
        }))
        alert.addAction(UIAlertAction(title: "Classic Spooky Ball", style: .default, handler: { _ in
            self.gameEngine.setPowerup(powerup: .spookyBall)
        }))
        alert.addAction(UIAlertAction(title: "Beat the Score", style: .default, handler: { _ in
            self.gameEngine.setGameMode(gameMode: .beatTheScore)
        }))
        alert.addAction(UIAlertAction(title: "Siam Left, Siam Right", style: .default, handler: { _ in
            self.gameEngine.setGameMode(gameMode: .siam)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func onGameOver(hasWon: Bool) {
        let title = hasWon ? "You Win!" : "You Lose :("
        let message = hasWon ? "Congratulations!" : "Better luck next time."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Back to Home", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "unwindToHomeFromGameplay", sender: self)
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
