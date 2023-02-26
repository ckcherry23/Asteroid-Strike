//
//  SavedLevel.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import Foundation

struct SavedLevel: Codable {
    let id: UUID
    private(set) var gameBoard: Gameboard
    private(set) var levelName: String

    init(gameBoard: Gameboard, levelName: String, id: UUID = UUID()) {
        self.id = id
        self.gameBoard = gameBoard
        self.levelName = levelName
    }
}
