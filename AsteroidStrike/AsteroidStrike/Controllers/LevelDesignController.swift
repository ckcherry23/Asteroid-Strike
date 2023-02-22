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

    override func viewDidLayoutSubviews() {
        levelDesigner.updateCanvasSize(canvas.bounds.size)
    }

    var selectedPaletteButton: PaletteButton?

    var levelDesigner: LevelDesigner = LevelDesigner() {
        didSet {
            observeModel()
        }
    }

    private(set) var levelStorage: LevelStorage = JSONLevelStorage()
    private(set) var selectedCanvasObject: (any CanvasObject)?

    @IBOutlet weak var bluePegButton: BluePegButton!
    @IBOutlet weak var orangePegButton: OrangePegButton!
    @IBOutlet weak var blockButton: BlockButton!
    @IBOutlet weak var eraseButton: EraseButton!
    @IBOutlet var paletteButtons: [PaletteButton]!
    @IBOutlet weak var canvas: UIImageView!
    @IBOutlet weak var levelNameTextField: UITextField!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var rotationSlider: UISlider!

    @IBAction func onTapCanvas(_ gestureRecognizer: UITapGestureRecognizer) {
        let taplocation: CGPoint = gestureRecognizer.location(in: canvas)
        selectedPaletteButton?.modifyGameboard(levelDesigner: levelDesigner, tappedLocation: taplocation)
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
            selectedCanvasObject = pegViewToAdd
        }

        for block in levelDesigner.gameboard.blocks
        where !canvas.subviews.compactMap({ ($0 as? BlockView)?.location }).contains(block.location) {
            let blockViewToAdd: BlockView = BlockView(at: block.location, size: block.size)
            setupCanvasObjectGestures(canvasObject: blockViewToAdd)
            canvas.addSubview(blockViewToAdd)
            selectedCanvasObject = blockViewToAdd
        }
    }

    private func removeErasedViews() {
        for canvasObject in canvas.subviews
        where !levelDesigner.gameboard.pegs.compactMap({ $0.location })
            .contains((canvasObject as? (any CanvasObject))?.location) {
            canvasObject.removeFromSuperview()
            if canvasObject == selectedCanvasObject {
                selectedCanvasObject = nil
            }
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
        selectedCanvasObject = draggedCanvasObject
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
