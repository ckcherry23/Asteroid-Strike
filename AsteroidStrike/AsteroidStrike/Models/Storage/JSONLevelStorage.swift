//
//  LevelStorage.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 26/1/23.
//
//  Referenced from Apple's iOS App Dev Tutorials:
//  https://developer.apple.com/tutorials/app-dev-training/persisting-data
//

import Foundation

struct JSONLevelStorage: LevelStorage {
    private let savedLevelsDirectory = "savedLevels"
    private let fileExtension = "json"
    private let fileManager = FileManager.default

    public func getAllLevelNames(completion: @escaping (Result<[String], Error>) -> Void) {
        do {
            let fileNames = try getAllFileNamesInDirectory(directoryName: savedLevelsDirectory)
            completion(.success(fileNames))
        } catch {
            completion(.failure(error))
        }
    }

    public func saveLevel(level: SavedLevel, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let encodedData = try JSONEncoder().encode(level)
            let savedLevelFileURL = try getSavedLevelFileURL(levelName: level.levelName)

            if !fileManager.fileExists(atPath: savedLevelFileURL.path()) {
                fileManager.createFile(atPath: savedLevelFileURL.path(), contents: encodedData)
            } else {
                deleteLevel(levelName: level.levelName, completion: {_ in })
                fileManager.createFile(atPath: savedLevelFileURL.path(), contents: encodedData)
            }

            completion(.success(level.levelName))
        } catch {
            completion(.failure(error))
        }
    }

    public func loadLevel(levelName: String, completion: @escaping (Result<SavedLevel, Error>) -> Void) {
        do {
            let savedLevelFileURL = try getSavedLevelFileURL(levelName: percentEncoded(levelName))
            let savedLevelFile = try FileHandle(forReadingFrom: savedLevelFileURL)
            let decodedData = try JSONDecoder().decode(SavedLevel.self, from: savedLevelFile.availableData)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }

    public func deleteLevel(levelName: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try fileManager.removeItem(at: getSavedLevelFileURL(levelName: percentEncoded(levelName)))
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }

    private func percentEncoded(_ levelName: String) -> String {
        return levelName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? levelName
    }

    private func getSavedLevelFileURL(levelName: String) throws -> URL {
        return try createAndGetSavedLevelsDirectoryURL()
            .appending(path: levelName)
            .appendingPathExtension(fileExtension)
    }

    private func getAllFileNamesInDirectory(directoryName: String) throws -> [String] {
        return try fileManager.contentsOfDirectory(at: createAndGetSavedLevelsDirectoryURL(),
                                                   includingPropertiesForKeys: nil)
        .compactMap({ $0.deletingPathExtension().lastPathComponent.removingPercentEncoding })
    }

    private func createAndGetSavedLevelsDirectoryURL() throws -> URL {
        let directoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask,
                                               appropriateFor: nil, create: true)
            .appending(path: savedLevelsDirectory)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL
    }
}
