//
//  CGPoint.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}

extension CGPoint {
    public func distanceFrom(other: CGPoint) -> CGFloat {
        sqrt(pow((x - other.x), 2) + pow((y - other.y), 2))
    }

    public func rotatedUpsideDown(frame: CGRect, superFrame: CGRect?) -> CGPoint {
        guard let superFrameRect = superFrame else {
            return CGPoint(x: frame.maxX - x, y: frame.maxY - y)
        }
        let bottomOffset = superFrameRect.maxY - frame.maxY - frame.minY + 20
        return CGPoint(x: frame.maxX - x, y: frame.maxY - y - bottomOffset)
    }
}
