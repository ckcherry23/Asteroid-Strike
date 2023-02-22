//
//  PegView.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 23/1/23.
//

import UIKit

class PegView: UIImageView, CanvasObject {
    var location: CGPoint
    var size: CGFloat {
        get {
            self.frame.height
        }
        set(newSize) {
            self.frame = CGRect.centeredRectangle(center: location, size: CGSize(width: newSize, height: newSize))
        }
    }
    var isHit: Bool = false {
        didSet {
            self.updatePegAppearance()
        }
    }

    fileprivate init(at location: CGPoint, radius: CGFloat) {
        let boundingBox = CGRect.boundingBoxForCircle(center: location, radius: radius)
        self.location = location
        super.init(frame: boundingBox)
        self.customize()
    }

    required init?(coder: NSCoder) {
        self.location = CGPoint.zero
        super.init(coder: coder)
    }

    private func customize() {
        self.layer.cornerRadius = bounds.size.width / 2
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFill
    }

    func updatePegAppearance() {}
}

extension PegView {
    func setupSliderViews(_ sizeSlider: UISlider, _ widthSlider: UISlider,
                          _ heightSlider: UISlider, _ rotationSlider: UISlider) {
        widthSlider.superview?.isHidden = true
        heightSlider.superview?.isHidden = true
        sizeSlider.superview?.isHidden = false
        rotationSlider.superview?.isHidden = false

        sizeSlider.value = Float(size)
    }
}

class BluePegView: PegView {
    override init(at location: CGPoint, radius: CGFloat) {
        super.init(at: location, radius: radius)
        updatePegAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updatePegAppearance() {
        if isHit {
            image = UIImage(named: "peg-blue-glow")
        } else {
            image = UIImage(named: "peg-blue")
        }
    }
}

class OrangePegView: PegView {
    override init(at location: CGPoint, radius: CGFloat) {
        super.init(at: location, radius: radius)
        updatePegAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updatePegAppearance() {
        if isHit {
            image = UIImage(named: "peg-orange-glow")
        } else {
            image = UIImage(named: "peg-orange")
        }
    }
}
