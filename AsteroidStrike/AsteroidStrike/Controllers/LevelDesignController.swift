//
//  LevelDesignController.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 19/1/23.
//

import UIKit

class LevelDesignController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        addKeyboardHandlers()
    }

    override func viewDidLayoutSubviews() {
        levelDesigner.updateCanvasSize(canvas.bounds.size)
    }

    var selectedPaletteButton: PaletteButton?

    var levelDesigner: LevelDesigner = LevelDesigner() {
        didSet {
            updateCanvas()
        }
    }
    private var levelStorage: LevelStorage = JSONLevelStorage()

    @IBOutlet weak var bluePegButton: PaletteButton!
    @IBOutlet weak var orangePegButton: PaletteButton!
    @IBOutlet weak var eraseButton: PaletteButton!
    @IBOutlet var paletteButtons: [PaletteButton]!
    @IBOutlet weak var canvas: UIImageView!
    @IBOutlet weak var levelNameTextField: UITextField!

    @IBAction func onTapPegButton(_ sender: PaletteButton) {
        clearAllSelections()
        sender.isSelected = true
        selectedPaletteButton = sender
    }

    @IBAction func onTapCanvas(_ gestureRecognizer: UITapGestureRecognizer) {
        let taplocation: CGPoint = gestureRecognizer.location(in: canvas)

        switch selectedPaletteButton {
        case bluePegButton:
            levelDesigner.addPegToGameboard(pegLocation: taplocation, pegColor: .blue)
        case orangePegButton:
            levelDesigner.addPegToGameboard(pegLocation: taplocation, pegColor: .orange)
        case eraseButton:
            levelDesigner.erasePegFromGameboard(tappedLocation: taplocation)
        default:
            break
        }
    }

    private func updateCanvas() {
        removeErasedViews()
        addNewViews()
    }

    private func addNewViews() {
        for peg in levelDesigner.gameboard.pegs
        where !canvas.subviews.compactMap({ ($0 as? PegView)?.location }).contains(peg.location) {
            let pegViewToAdd: PegView
            switch peg.color {
            case .blue:
                pegViewToAdd = BluePegView(at: peg.location, radius: peg.radius)
            case .orange:
                pegViewToAdd = OrangePegView(at: peg.location, radius: peg.radius)
            }
            setupPegGestures(pegView: pegViewToAdd)
            canvas.addSubview(pegViewToAdd)
        }
    }

    private func removeErasedViews() {
        for pegView in canvas.subviews
        where !levelDesigner.gameboard.pegs.compactMap({ $0.location }).contains((pegView as? PegView)?.location) {
            pegView.removeFromSuperview()
        }
    }

    private func setupPegGestures(pegView: PegView) {
        makePegDraggable(pegView: pegView)
        allowPegLongPress(pegView: pegView)
    }

    private func makePegDraggable(pegView: PegView) {
        let pegDragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onDragPeg(_:)))
        pegView.addGestureRecognizer(pegDragGestureRecognizer)
    }

    private func allowPegLongPress(pegView: PegView) {
        let pegLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                         action: #selector(onLongPressPeg(_:)))
        pegView.addGestureRecognizer(pegLongPressGestureRecognizer)
    }

    @IBAction func onDragPeg(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let draggedPeg = gestureRecognizer.view as? PegView else {
            return
        }
        let oldLocation: CGPoint = draggedPeg.center
        let newLocation = gestureRecognizer.location(in: canvas)

        // Move peg view location on canvas
        draggedPeg.center = newLocation
        draggedPeg.location = newLocation

        let isMoveValid = levelDesigner.movePegOnGameboard(oldLocation: oldLocation, newLocation: newLocation)
        if !isMoveValid {
            // Undo move of peg view on canvas
            draggedPeg.center = oldLocation
            draggedPeg.location = oldLocation
        }
    }

    @IBAction func onLongPressPeg(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let longPressLocation = gestureRecognizer.location(in: canvas)
        levelDesigner.erasePegFromGameboard(tappedLocation: longPressLocation)
    }

    private func clearAllSelections() {
        paletteButtons.forEach { $0.isSelected = false }
    }

    private func setDefaults() {
        bluePegButton.isSelected = true
        canvas.translatesAutoresizingMaskIntoConstraints = false
        selectedPaletteButton = bluePegButton
    }
}

extension LevelDesignController {

    @IBAction func onTapResetButton(_ sender: Any) {
        levelDesigner = LevelDesigner()
    }

    @IBAction func onTapSaveButton(_ sender: Any) {
        guard let levelName = levelNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        let newLevel: SavedLevel = SavedLevel(gameBoard: levelDesigner.gameboard, levelName: levelName)
        levelStorage.saveLevel(level: newLevel) {result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }

    @IBAction private func unwindToLevelDesign(sender: UIStoryboardSegue) {
        guard let levelSelectController = sender.source as? LevelSelectController,
              let loadedLevel = levelSelectController.loadedLevel
        else {
            return
        }
        levelDesigner.updateGameboardFromLoadedLevel(savedLevel: loadedLevel)
        levelNameTextField.text = loadedLevel.levelName
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showSegueWithGameboard",
              let gameplayController: GameplayController = segue.destination as? GameplayController else {
            return
        }
        gameplayController.gameboardDelegate = self
    }

    // Move view with keyboard
    // Referenced from https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    //
    private func addKeyboardHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                  as? NSValue)?.cgRectValue else {
            return
        }
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardRect.height
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension LevelDesignController: GameboardDelegate {
    func getGameBoard() -> Gameboard? {
        // Copy the gameboard to reset hits from previous plays
        levelDesigner.gameboard.copy()
    }
}
