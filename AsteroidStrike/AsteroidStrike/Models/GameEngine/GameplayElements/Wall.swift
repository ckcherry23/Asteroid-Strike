//
//  Wall.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 12/2/23.
//

import CoreGraphics

struct Wall {
    private static let defaultMass: CGFloat = 10

    private(set) var physicsBody: EdgePhysicsBody

    init(edge: RectangleEdges.Edge) {
        self.physicsBody = EdgePhysicsBody(source: edge.source, destination: edge.destination)
        physicsBody.isDynamic = false
        physicsBody.isAffectedByGravity = false
        physicsBody.mass = Wall.defaultMass
    }
}
