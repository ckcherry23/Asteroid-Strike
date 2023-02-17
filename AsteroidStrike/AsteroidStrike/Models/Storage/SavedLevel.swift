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

    init(id: UUID = UUID(), gameBoard: Gameboard, levelName: String) {
        self.id = id
        self.gameBoard = gameBoard
        self.levelName = levelName
    }
}
