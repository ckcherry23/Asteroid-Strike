//
//  GameboardObject.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

protocol GameboardObject: Codable {
    var hitBox: CGPath { get }
    func isOverlapping(gameboardObject: GameboardObject) -> Bool
    func isWithin(path: CGPath) -> Bool
}

extension GameboardObject {
    func isOverlapping(gameboardObject: GameboardObject) -> Bool {
        self.hitBox.intersects(gameboardObject.hitBox)
    }

    func isWithin(path: CGPath) -> Bool {
        self.hitBox.subtracting(path).isEmpty
    }
}
