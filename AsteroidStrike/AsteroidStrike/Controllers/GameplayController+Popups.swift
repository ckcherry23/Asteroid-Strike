//
//  GameplayController+Popups.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 23/2/23.
//

import UIKit

extension GameplayController {
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
