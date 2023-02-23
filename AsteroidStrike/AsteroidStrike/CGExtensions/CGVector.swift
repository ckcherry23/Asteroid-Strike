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
    func squaredLength() -> CGFloat {
        return dx * dx + dy * dy
    }

    func length() -> CGFloat {
        return sqrt(squaredLength())
    }

    func normalized() -> CGVector {
        return self / self.length()
    }

    func normal() -> CGVector {
        return CGVector(dx: -dy, dy: dx)
    }
}

extension CGVector {
    static func getClosestEdgeVector(rectangleBody: RectanglePhysicsBody, circleBody: CirclePhysicsBody) -> CGVector? {
        var closestEdge = rectangleBody.rect.getEdges(angle: rectangleBody.angle).left
        var closestEdgeDistance = CGFloat.infinity

        for edge in rectangleBody.rect.getEdges(angle: rectangleBody.angle).edges {
            let squaredDistance = findSquaredDistanceFromCircle(edge: edge, circleBody: circleBody)
            if squaredDistance < closestEdgeDistance {
                closestEdgeDistance = squaredDistance
                closestEdge = edge
            } else if squaredDistance == closestEdgeDistance {
                // closest point at corner not edge
                return nil
            }
        }
        return CGVector.vector(fromPoint: closestEdge.destination) - CGVector.vector(fromPoint: closestEdge.source)
    }

    //
    // Find distance of point from line
    // Referenced from: https://stackoverflow.com/questions/70795702/
    //                  is-there-an-efficient-way-to-find-the-nearest-line-segment-to-a-point-in-3-dimen
    //
    private static func findSquaredDistanceFromCircle(edge: RectangleEdges.Edge,
                                                      circleBody: CirclePhysicsBody) -> CGFloat {
        let edgeVector = CGVector.vector(fromPoint: edge.destination) - CGVector.vector(fromPoint: edge.source)
        let sourceToCircle = circleBody.position - CGVector.vector(fromPoint: edge.source)
        let destToCircle = circleBody.position - CGVector.vector(fromPoint: edge.destination)

        let projection = edgeVector * ((sourceToCircle * edgeVector) / (edgeVector * edgeVector))
        let orthoComplement = sourceToCircle - projection

        let sourceToCircleDistSquared = sourceToCircle * sourceToCircle
        let destToCircleDistSquared = destToCircle * destToCircle
        let pointRectDistance = orthoComplement * orthoComplement

        let coefficient = projection * edgeVector
        var squaredDistance: CGFloat

        if coefficient < 0 {
            squaredDistance = sourceToCircleDistSquared
        } else if coefficient < edgeVector * edgeVector {
            squaredDistance = pointRectDistance
        } else {
            squaredDistance = destToCircleDistSquared
        }
        return squaredDistance
    }
}
