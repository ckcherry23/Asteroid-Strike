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
    @IBOutlet weak var blockButton: PaletteButton!
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
            levelDesigner.addPegToGameboard(pegLocation: taplocation, pegType: .blue)
        case orangePegButton:
            levelDesigner.addPegToGameboard(pegLocation: taplocation, pegType: .orange)
        case blockButton:
            levelDesigner.addBlockToGameboard(blockLocation: taplocation)
        case eraseButton:
            levelDesigner.eraseObjectFromGameboard(tappedLocation: taplocation)
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
            switch peg.type {
            case .blue:
                pegViewToAdd = BluePegView(at: peg.location, radius: peg.radius)
            case .orange:
                pegViewToAdd = OrangePegView(at: peg.location, radius: peg.radius)
            }
            setupCanvasObjectGestures(canvasObject: pegViewToAdd)
            canvas.addSubview(pegViewToAdd)
        }

        for block in levelDesigner.gameboard.blocks
        where !canvas.subviews.compactMap({ ($0 as? BlockView)?.location }).contains(block.location) {
            let blockViewToAdd: BlockView = BlockView(at: block.location, size: block.size)
            setupCanvasObjectGestures(canvasObject: blockViewToAdd)
            canvas.addSubview(blockViewToAdd)
        }
    }

    private func removeErasedViews() {
        for canvasObject in canvas.subviews
        where !levelDesigner.gameboard.pegs.compactMap({ $0.location })
            .contains((canvasObject as? (any CanvasObject))?.location) {
            canvasObject.removeFromSuperview()
        }
    }

    private func setupCanvasObjectGestures(canvasObject: any CanvasObject) {
        makeCanvasObjectDraggable(canvasObject: canvasObject)
        allowCanvasObjectLongPress(canvasObject: canvasObject)
    }

    private func makeCanvasObjectDraggable(canvasObject: any CanvasObject) {
        let canvasObjectDragGestureRecognizer = UIPanGestureRecognizer(
            target: self, action: #selector(onDragCanvasObject(_:)))
        canvasObject.addGestureRecognizer(canvasObjectDragGestureRecognizer)
    }

    private func allowCanvasObjectLongPress(canvasObject: any CanvasObject) {
        let canvasObjectLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                         action: #selector(onLongPressCanvasObject(_:)))
        canvasObject.addGestureRecognizer(canvasObjectLongPressGestureRecognizer)
    }

    @IBAction func onDragCanvasObject(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let draggedCanvasObject = gestureRecognizer.view as? (any CanvasObject) else {
            return
        }
        let oldLocation: CGPoint = draggedCanvasObject.center
        let newLocation = gestureRecognizer.location(in: canvas)

        // Move view location on canvas
        draggedCanvasObject.center = newLocation

        if gestureRecognizer.state == .ended {
            let isMoveValid = levelDesigner.moveObjectOnGameboard(
                oldLocation: draggedCanvasObject.location ?? oldLocation, newLocation: newLocation)
            if isMoveValid {
                draggedCanvasObject.location = newLocation
            } else {
                // Undo move of view on canvas
                draggedCanvasObject.center = draggedCanvasObject.location ?? oldLocation
            }
        }
    }

    @IBAction func onLongPressCanvasObject(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let longPressLocation = gestureRecognizer.location(in: canvas)
        levelDesigner.eraseObjectFromGameboard(tappedLocation: longPressLocation)
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
