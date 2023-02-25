//
//  GameMode.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 23/2/23.
//

import Foundation

protocol GameMode {
    var isTimerNeeded: Bool { get }
    var hasTargetScore: Bool { get }
    var totalBallsCount: Int { get }
    var timeLimit: TimeInterval { get }
    var targetScore: Int { get }
    var hasWon: Bool { get }
    var hasLost: Bool { get }
    func isGameOver() -> Bool
    func onEnterBucket()
}

extension GameMode {
    func isGameOver() -> Bool {
        hasWon || hasLost
    }
}

enum GameModeType {
    case classic
    case beatTheScore
    case siam

    static let gameModeMapping: [GameModeType: (GameEngine) -> (GameMode)] = [
        .classic: { (gameEngine) in ClassicMode(gameEngine: gameEngine) },
        .beatTheScore: { (gameEngine) in BeatTheScoreMode(gameEngine: gameEngine) },
        .siam: { (gameEngine) in SiamMode(gameEngine: gameEngine) }
    ]
}
