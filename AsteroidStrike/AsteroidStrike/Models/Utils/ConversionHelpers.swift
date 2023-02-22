//
//  ConversionHelpers.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 23/2/23.
//

import CoreGraphics

class Convert {
    static func radiansToDegrees(angleInRadians: CGFloat) -> CGFloat {
        angleInRadians * 180 / .pi
    }

    static func degreesToRadians(angleInDegrees: CGFloat) -> CGFloat {
        angleInDegrees * .pi / 180
    }
}
