//
//  CGRect.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 24/1/23.
//

import CoreGraphics

extension CGRect {
    static func centeredRectangle(center: CGPoint, size: CGSize) -> CGRect {
        let rectOrigin = CGPoint(x: Int(center.x) - Int(size.width / 2), y: Int(center.y) - Int(size.height / 2))
        return CGRect(origin: rectOrigin, size: size)
    }

    static func boundingBoxForCircle(center: CGPoint, radius: CGFloat) -> CGRect {
        let diameter = Int(radius) * 2
        let boundingBoxOrigin = (x: Int(center.x) - Int(radius), y: Int(center.y) - Int(radius))
        return CGRect(x: boundingBoxOrigin.x, y: boundingBoxOrigin.y, width: diameter, height: diameter)
    }

    func getCorners(angle: CGFloat = 0.0) -> RectangleCorners {
        let rotationTransform = CGAffineTransform(rotationAngle: angle)
        let topLeft = CGPoint(x: minX, y: minY).applying(rotationTransform)
        let bottomLeft = CGPoint(x: minX, y: maxY).applying(rotationTransform)
        let bottomRight = CGPoint(x: maxX, y: maxY).applying(rotationTransform)
        let topRight = CGPoint(x: maxX, y: minY).applying(rotationTransform)

        return RectangleCorners(topLeft: topLeft, bottomLeft: bottomLeft, bottomRight: bottomRight, topRight: topRight)
    }

    func getEdges(angle: CGFloat = 0.0) -> RectangleEdges {
        let corners: RectangleCorners = getCorners(angle: angle)
        let left = (source: corners.topLeft, destination: corners.bottomLeft)
        let bottom = (source: corners.bottomLeft, destination: corners.bottomRight)
        let right = (source: corners.bottomRight, destination: corners.topRight)
        let top = (source: corners.topRight, destination: corners.topLeft)

        return RectangleEdges(left: left, bottom: bottom, right: right, top: top)
    }
}

struct RectangleCorners {
    var topLeft: CGPoint
    var bottomLeft: CGPoint
    var bottomRight: CGPoint
    var topRight: CGPoint
    var corners: [CGPoint] {
        [topLeft, bottomLeft, bottomRight, topRight]
    }
}

struct RectangleEdges {
    typealias Edge = (source: CGPoint, destination: CGPoint)
    var left: Edge
    var bottom: Edge
    var right: Edge
    var top: Edge
    var edges: [Edge] {
        [left, bottom, right, top]
    }}
