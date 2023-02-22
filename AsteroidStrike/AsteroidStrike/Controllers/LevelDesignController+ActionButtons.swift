//
//  LevelDesignController+ActionButtons.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 22/2/23.
//

import UIKit

extension LevelDesignController {
    @IBAction func onTapResetButton(_ sender: Any) {
        levelDesigner = LevelDesigner()
    }

    @IBAction func onTapSaveButton(_ sender: Any) {
        guard let levelName = levelNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        let newLevel: SavedLevel = SavedLevel(gameBoard: levelDesigner.gameboard, levelName: levelName)
        levelStorage.saveLevel(level: newLevel) {result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }

    @IBAction private func unwindToLevelDesign(sender: UIStoryboardSegue) {
        guard let levelSelectController = sender.source as? LevelSelectController,
              let loadedLevel = levelSelectController.loadedLevel
        else {
            return
        }
        levelDesigner.updateGameboardFromLoadedLevel(savedLevel: loadedLevel)
        levelNameTextField.text = loadedLevel.levelName
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showSegueWithGameboard",
              let gameplayController: GameplayController = segue.destination as? GameplayController else {
            return
        }
        gameplayController.gameboardDelegate = self
    }

    // Move view with keyboard
    // Referenced from https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    //
     func addKeyboardHandlers() {
         NotificationCenter.default.addObserver(self, selector:
                                                    #selector(keyboardWillShow),
                                                name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector:
                                                    #selector(keyboardWillHide),
                                                name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                  as? NSValue)?.cgRectValue else {
            return
        }
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardRect.height
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
