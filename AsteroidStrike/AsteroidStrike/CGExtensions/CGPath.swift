//
//  CGPath.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 11/2/23.
//

import CoreGraphics
import UIKit

extension CGPath {
    func translate(from position: CGVector, to newPosition: CGVector) -> CGPath {
        let bezierPath = UIBezierPath(cgPath: self)
        bezierPath.apply(CGAffineTransformMakeTranslation(newPosition.dx - position.dx,
                                                          newPosition.dy - position.dy))
        return bezierPath.cgPath
    }
}
