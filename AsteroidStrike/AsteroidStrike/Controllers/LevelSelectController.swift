//
//  LevelSelectController.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 26/1/23.
//

import UIKit

class LevelSelectController: UITableViewController {
    private let numberOfSections = 1
    private let sectionTitle = "Select Level"
    private var savedLevelNames: [String] = []
    private(set) var loadedLevel: SavedLevel?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTableData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
       return numberOfSections
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return savedLevelNames.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyleCell", for: indexPath)
        cell.textLabel!.text = savedLevelNames[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLevelName = savedLevelNames[indexPath.row]
        LevelStorage.loadLevel(levelName: selectedLevelName, completion: { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let level):
                self.loadedLevel = level
            }
        })
        self.performSegue(withIdentifier: "unwindToLevelDesign", sender: self)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            LevelStorage.deleteLevel(levelName: savedLevelNames[indexPath.row], completion: { result in
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
    }

    private func getSavedLevelNames() {
        LevelStorage.getAllLevelNames { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let levelNames):
                self.savedLevelNames = levelNames
            }
        }
    }
}
