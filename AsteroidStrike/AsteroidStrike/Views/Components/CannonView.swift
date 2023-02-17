//
//  CannonView.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 8/2/23.
//

import UIKit

class CannonView: UIImageView {
    func rotate(by angle: CGFloat) {
        let rangedAngle = limitAngleInRange(angle)
        self.transform = CGAffineTransform(rotationAngle: rangedAngle)
    }

    private func limitAngleInRange(_ angle: CGFloat) -> CGFloat {
        var rangedAngle: CGFloat = angle
        if angle > .pi / 2 {
            rangedAngle = .pi / 2
        } else if angle < -(.pi / 2) {
            rangedAngle = -(.pi / 2)
        }
        return rangedAngle
    }
}
