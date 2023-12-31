//
//  LevelSelectController.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 26/1/23.
//

import UIKit

class LevelSelectController: UITableViewController {
    private let numberOfSections = 2
    private let sectionTitles = ["Default Levels", "Your Saved Levels"]

    private var preloadedLevelNames: [String] = []
    private var savedLevelNames: [String] = []
    private(set) var loadedLevel: SavedLevel?

    private var levelCounts: [Int] {
        [preloadedLevelNames.count, savedLevelNames.count]
    }

    private var levelStorage: LevelStorage = JSONLevelStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTableData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSections
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        levelCounts[section]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let sectionToLevelNamesMapping: [Int: (Int) -> String] = [
            0: { row in self.preloadedLevelNames[row] },
            1: { row in self.savedLevelNames[row] }
        ]
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyleCell", for: indexPath)
        guard let levelNames = sectionToLevelNamesMapping[indexPath.section] else {
            return cell
        }
        cell.textLabel!.text = levelNames(indexPath.row)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.loadedLevel = PreloadedLevels(size: UIScreen.main.bounds.size)
                .preloadedLevels[indexPath.row]
        } else if indexPath.section == 1 {
            let selectedLevelName = savedLevelNames[indexPath.row]
            levelStorage.loadLevel(levelName: selectedLevelName, completion: { result in
                switch result {
                case .failure:
                    self.showInvalidLevelModal()
                    return
                case .success(let level):
                    self.loadedLevel = level
                }
            })
        }

        guard loadedLevel?.gameBoard.isValidLevel() != false else {
            showInvalidLevelModal()
            return
        }
        self.performSegue(withIdentifier: "unwindToLevelDesign", sender: self)
        self.performSegue(withIdentifier: "showSegueWithLoadedLevel", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showSegueWithLoadedLevel",
              let gameplayController: GameplayController = segue.destination as? GameplayController else {
            return
        }
        gameplayController.gameboardDelegate = self
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section != 0 {
            levelStorage.deleteLevel(levelName: savedLevelNames[indexPath.row], completion: { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success:
                    self.savedLevelNames.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
        }
    }

    private func fetchTableData() {
        getSavedLevelNames()
        getPreloadedLevelNames()
    }

    private func getSavedLevelNames() {
        levelStorage.getAllLevelNames { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let levelNames):
                self.savedLevelNames = levelNames
            }
        }
    }

    private func getPreloadedLevelNames() {
        preloadedLevelNames = PreloadedLevels.preloadedLevelNames
    }
}

extension LevelSelectController: GameboardDelegate {
    func getGameBoard() -> Gameboard? {
        loadedLevel?.gameBoard
    }
}

protocol GameboardDelegate: AnyObject {
    func getGameBoard() -> Gameboard?
}
