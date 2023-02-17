//
//  PhysicsBodyProtocols.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 12/2/23.
//

import Foundation

protocol Movable {
    func applyForce(newForce: CGVector)
    func applyImpulse(impulse: CGVector)
}

protocol Collidable {
    func detectCollision(other: PhysicsBody) -> PhysicsCollision?
}
