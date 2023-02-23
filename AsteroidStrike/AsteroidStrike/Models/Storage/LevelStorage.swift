//
//  LevelStorage.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 24/2/23.
//

protocol LevelStorage {
    func getAllLevelNames(completion: @escaping (Result<[String], Error>) -> Void)
    func saveLevel(level: SavedLevel, completion: @escaping (Result<String, Error>) -> Void)
    func loadLevel(levelName: String, completion: @escaping (Result<SavedLevel, Error>) -> Void)
    func deleteLevel(levelName: String, completion: @escaping (Result<Bool, Error>) -> Void)
}
