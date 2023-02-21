//
//  CGVector.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 5/2/23.
//

import CoreGraphics

extension CGVector {
    static func vector(fromPoint: CGPoint) -> CGVector {
        CGVector(dx: fromPoint.x, dy: fromPoint.y)
    }
}

// Operator Overriding
extension CGVector {
    static prefix func - (vector: CGVector) -> CGVector {
        CGVector(dx: -vector.dx, dy: -vector.dy)
    }

    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }

    static func / (vector: CGVector, scalar: CGFloat) -> CGVector {
        CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }

    static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    static func * (lhs: CGVector, rhs: CGVector) -> CGFloat {
        lhs.dx * rhs.dx + lhs.dy * rhs.dy // dot product
    }

    static func += (lhs: inout CGVector, rhs: CGVector) {
        lhs = CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    static func -= (lhs: inout CGVector, rhs: CGVector) {
        lhs = CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
}

// Vector Properties
extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    func normalized() -> CGVector {
        return self / self.length()
    }

    func normal() -> CGVector {
        return CGVector(dx: -dy, dy: dx)
    }
}
