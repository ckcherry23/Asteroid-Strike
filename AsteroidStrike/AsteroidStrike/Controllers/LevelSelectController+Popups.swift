//
//  LevelSelectController+Popups.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 26/2/23.
//

import UIKit

extension LevelSelectController {
    func showInvalidLevelModal() {
        let title = "Level Invalid"
        let message = "The selected level is not playable as it does not have at least one orange peg."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
    }
}
