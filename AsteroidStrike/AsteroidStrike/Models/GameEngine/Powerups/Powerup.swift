//
//  Powerup.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

protocol Powerup {
    var isPowerupActivated: Bool { get }
    func handlePowerup()
}

extension Powerup {
    func getGreenHitPegs(gameEngine: GameEngine) -> [Peg] {
        gameEngine.gameboard.pegs.filter({ $0.type == .green && $0.isHit })
    }
}
