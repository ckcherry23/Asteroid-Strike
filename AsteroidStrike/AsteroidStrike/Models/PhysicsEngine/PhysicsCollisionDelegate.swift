//
//  PhysicsCollisionDelegate.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

protocol PhysicsCollisionDelegate: AnyObject {
    func onCollision(physicsCollision: PhysicsCollision)
}
