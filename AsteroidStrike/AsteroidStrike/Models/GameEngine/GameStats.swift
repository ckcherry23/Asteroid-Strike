//
//  GameStats.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 25/2/23.
//

import Foundation

struct GameStats {
    var remainingBallsCount: Int = GameEngine.defaultBallCount
    var timeRemaining = TimeInterval.infinity
    var score: Int = 0
}
