//
//  PhysicsBodyCategory.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

struct PhysicsBodyCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let ball: UInt32 = UInt32.max
    static let activePowerup: UInt32 = 0b10
    static let deactivatedPowerup: UInt32 = UInt32.max
}
