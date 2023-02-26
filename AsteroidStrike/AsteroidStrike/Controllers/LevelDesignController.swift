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
        observeModel()
    }

    var selectedPaletteButton: PaletteButton?

    var levelDesigner = LevelDesigner() {
        didSet {
            observeModel()
            updateCanvas()
        }
    }

    private(set) var levelStorage: LevelStorage = JSONLevelStorage()
    private(set) var selectedCanvasObject: (any CanvasObject)?

    @IBOutlet private var bluePegButton: BluePegButton!
    @IBOutlet private var orangePegButton: OrangePegButton!
    @IBOutlet private var greenPegButton: GreenPegButton!
    @IBOutlet private var blockButton: BlockButton!
    @IBOutlet private var eraseButton: EraseButton!
    @IBOutlet private var paletteButtons: [PaletteButton]!
    @IBOutlet private var canvas: UIImageView!
    @IBOutlet private var levelNameTextField: UITextField!
    @IBOutlet private var sizeSlider: UISlider!
    @IBOutlet private var widthSlider: UISlider!
    @IBOutlet private var heightSlider: UISlider!
    @IBOutlet private var rotationSlider: UISlider!

    @IBAction private func onTapCanvas(_ gestureRecognizer: UITapGestureRecognizer) {
        let taplocation: CGPoint = gestureRecognizer.location(in: canvas)
        guard let modifyGameboard =
                selectedPaletteButton?.getModifyGameboardClosure(levelDesigner: levelDesigner) else {
            return
        }
        modifyGameboard(taplocation)
    }

    private func updateCanvas() {
        removeErasedViews()
        addNewViews()
    }

    private func addNewViews() {
        for peg in levelDesigner.gameboard.pegs
        where !canvas.subviews.compactMap({ ($0 as? PegView)?.location }).contains(peg.location) {
            guard let createPegViewFromPeg = PegType.pegViewMapping[peg.type] else {
                continue
            }
            let pegViewToAdd: PegView = createPegViewFromPeg(peg)
            setupCanvasObjectGestures(canvasObject: pegViewToAdd)
            canvas.addSubview(pegViewToAdd)
        }

        for block in levelDesigner.gameboard.blocks
        where !canvas.subviews.compactMap({ ($0 as? BlockView)?.location }).contains(block.location) {
            let blockViewToAdd = BlockView(at: block.location, size: block.size, angle: block.angle)
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
        allowCanvasObjectTap(canvasObject: canvasObject)
        makeCanvasObjectDraggable(canvasObject: canvasObject)
        allowCanvasObjectLongPress(canvasObject: canvasObject)
    }

    private func allowCanvasObjectTap(canvasObject: any CanvasObject) {
        let canvasObjectTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onTapCanvasObject(_:)))
        canvasObject.addGestureRecognizer(canvasObjectTapGestureRecognizer)
    }

    private func makeCanvasObjectDraggable(canvasObject: any CanvasObject) {
        let canvasObjectDragGestureRecognizer = UIPanGestureRecognizer(
            target: self, action: #selector(onDragCanvasObject(_:)))
        canvasObject.addGestureRecognizer(canvasObjectDragGestureRecognizer)
    }

    private func allowCanvasObjectLongPress(canvasObject: any CanvasObject) {
        let canvasObjectLongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self, action: #selector(onLongPressCanvasObject(_:)))
        canvasObject.addGestureRecognizer(canvasObjectLongPressGestureRecognizer)
    }

    @IBAction private func onTapCanvasObject(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let tappedCanvasObject = gestureRecognizer.view as? (any CanvasObject) else {
            return
        }
        if selectedPaletteButton == eraseButton {
            levelDesigner.eraseObjectFromGameboard(tappedLocation: tappedCanvasObject.location)
            return
        }
        tappedCanvasObject.setupSliderViews(sizeSlider, widthSlider, heightSlider, rotationSlider)
        selectedCanvasObject = tappedCanvasObject
    }

    @IBAction private func onDragCanvasObject(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let draggedCanvasObject = gestureRecognizer.view as? (any CanvasObject) else {
            return
        }
        let newLocation = gestureRecognizer.location(in: canvas)

        // Move view location on canvas
        draggedCanvasObject.center = newLocation

        if gestureRecognizer.state == .ended {
            let isMoveValid = levelDesigner.moveObjectOnGameboard(
                oldLocation: draggedCanvasObject.location, newLocation: newLocation)
            if isMoveValid {
                draggedCanvasObject.location = newLocation
            } else {
                // Undo move of view on canvas
                draggedCanvasObject.center = draggedCanvasObject.location
            }
        }
    }

    @IBAction private func onLongPressCanvasObject(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let longPressLocation = gestureRecognizer.location(in: canvas)
        levelDesigner.eraseObjectFromGameboard(tappedLocation: longPressLocation)
    }

    @IBAction private func onTapSaveButton(_ sender: Any) {
        guard let levelName = levelNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        let newLevel = SavedLevel(gameBoard: levelDesigner.gameboard, levelName: levelName)
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

    @IBAction private func onTapPaletteButton(_ sender: PaletteButton) {
        clearAllSelections()
        sender.isSelected = true
        selectedPaletteButton = sender
    }

    @IBAction private func onSizeSliderValueChanged(_ sender: UISlider) {
        guard let pegView = selectedCanvasObject as? PegView else {
            return
        }
        let isResizeValid = levelDesigner.resizePegOnGameboard(pegLocation: pegView.location,
                                                               newSize: CGFloat(sizeSlider.value))
        if isResizeValid {
            pegView.size = CGFloat(sizeSlider.value)
        }
    }

    @IBAction private func onWidthSliderValueChanged(_ sender: UISlider) {
        guard let blockView = selectedCanvasObject as? BlockView else {
            return
        }
        let isResizeValid = levelDesigner.resizeBlockOnGameboard(
            blockLocation: blockView.location,
            newSize: CGSize(width: CGFloat(widthSlider.value), height: blockView.size.height))
        if isResizeValid {
            blockView.setSize(newSize: CGSize(width: CGFloat(widthSlider.value), height: blockView.size.height))
        }
    }

    @IBAction private func onHeightSliderValueChanged(_ sender: UISlider) {
        guard let blockView = selectedCanvasObject as? BlockView else {
            return
        }
        let isResizeValid = levelDesigner.resizeBlockOnGameboard(
            blockLocation: blockView.location,
            newSize: CGSize(width: blockView.size.width, height: CGFloat(heightSlider.value)))
        if isResizeValid {
            blockView.setSize(newSize: CGSize(width: blockView.size.width, height: CGFloat(heightSlider.value)))
        }
    }

    @IBAction private func onRotationSliderValueChanged(_ sender: UISlider) {
        guard let canvasObject = selectedCanvasObject else {
            return
        }
        let isRotationValid = levelDesigner.rotateObjectOnGameboard(
            location: canvasObject.location,
            newAngle: Convert.degreesToRadians(angleInDegrees: CGFloat(rotationSlider.value)))
        if isRotationValid {
            canvasObject.setAngle(newAngle: Convert.degreesToRadians(angleInDegrees: CGFloat(rotationSlider.value)))
        }
    }

    func setDefaults() {
        bluePegButton.isSelected = true
        canvas.translatesAutoresizingMaskIntoConstraints = false
        selectedPaletteButton = bluePegButton
    }

    private func clearAllSelections() {
        paletteButtons.forEach { $0.isSelected = false }
    }
}

extension LevelDesignController: Observer {
    func update() {
        updateCanvas()
    }

    func observeModel() {
        levelDesigner.attach(observer: self)
    }
}

extension LevelDesignController: GameboardDelegate {
    func getGameBoard() -> Gameboard? {
        // Copy the gameboard to reset hits from previous plays
        levelDesigner.gameboard.copy()
    }
}
