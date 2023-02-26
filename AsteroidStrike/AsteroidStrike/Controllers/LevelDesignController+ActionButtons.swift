//
//  LevelDesignController+ActionButtons.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 22/2/23.
//

import UIKit

extension LevelDesignController {
    @IBAction private func onTapResetButton(_ sender: Any) {
        levelDesigner = LevelDesigner()
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
