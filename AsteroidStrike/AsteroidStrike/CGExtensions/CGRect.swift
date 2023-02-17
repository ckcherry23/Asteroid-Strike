//
//  CGRect.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 24/1/23.
//

import CoreGraphics

extension CGRect {
    static func boundingBoxForCircle(center: CGPoint, radius: CGFloat) -> CGRect {
        let diameter = Int(radius) * 2
        let boundingBoxOrigin = (x: Int(center.x) - Int(radius), y: Int(center.y) - Int(radius))
        return CGRect(x: boundingBoxOrigin.x, y: boundingBoxOrigin.y, width: diameter, height: diameter)
    }

    func getCorners() -> RectangleCorners {
        let topLeft = CGPoint(x: minX, y: minY)
        let bottomLeft = CGPoint(x: minX, y: maxY)
        let bottomRight = CGPoint(x: maxX, y: maxY)
        let topRight = CGPoint(x: maxX, y: minY)

        return RectangleCorners(topLeft: topLeft, bottomLeft: bottomLeft, bottomRight: bottomRight, topRight: topRight)
    }

    func getEdges() -> RectangleEdges {
        let corners: RectangleCorners = getCorners()
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
}

struct RectangleEdges {
    typealias Edge = (source: CGPoint, destination: CGPoint)
    var left: Edge
    var bottom: Edge
    var right: Edge
    var top: Edge
}
