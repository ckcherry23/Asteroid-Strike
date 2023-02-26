//
//  LevelDesignController+Popups.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 22/2/23.
//

import UIKit

extension LevelDesignController {
    func showLoadLevelErrorModal() {
        let title = "Level Not Found"
        let message = "The level you have chosen could not be loaded. Please try loading another level."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
    }

    func showInvalidLevelNameModal() {
        let title = "Level Name Invalid"
        let message = "Please try a different level name that is not empty or reserved."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
    }

    func showInvalidLevelDesignModal() {
        let title = "Level Design Invalid"
        let message = "Please add at least one orange peg in your level design so that you can play it."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
    }

    func showSaveLevelSuccessModal(levelName: String) {
        let title = "Level Saved Successfully"
        let message = "The level \(levelName) has been saved successfully. " +
        "It can be loaded again to modify or play a game."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
    }

    func showSaveLevelFailureModal(error: String) {
        let title = "Level Not Saved"
        let message = "The level could not be saved. \(error)"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
    }

    func showLevelNameExistsModal() {
        let title = "Level Name Exists"
        let message = "Please save your level with another name."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
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
