//
//  PowerupMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

enum PowerupMode {
    case kaboom
    case spookyBall

    static let powerupMapping: [PowerupMode: (GameEngine) -> (Powerup)] = [
        .kaboom: { gameEngine in KaboomPowerup(gameEngine: gameEngine) },
        .spookyBall: { gameEngine in SpookyBallPowerup(gameEngine: gameEngine) }
    ]
}
