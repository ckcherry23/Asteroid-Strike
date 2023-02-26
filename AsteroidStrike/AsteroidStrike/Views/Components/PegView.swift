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
    var isHit = false {
        didSet {
            self.updatePegAppearance()
        }
    }
    var angle: CGFloat

    fileprivate init(at location: CGPoint, radius: CGFloat, angle: CGFloat) {
        let boundingBox = CGRect.boundingBoxForCircle(center: location, radius: radius)
        self.location = location
        self.angle = angle
        super.init(frame: boundingBox)
        self.customize()
    }

    required init?(coder: NSCoder) {
        self.location = CGPoint.zero
        self.angle = CGFloat.zero
        super.init(coder: coder)
    }

    func setAngle(newAngle: CGFloat) {
        angle = newAngle
        self.transform = CGAffineTransform(rotationAngle: newAngle)
    }

    func updatePegAppearance() {}

    private func customize() {
        self.layer.cornerRadius = bounds.size.width / 2
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFill
        self.transform = CGAffineTransform(rotationAngle: angle)
    }
}

extension PegView {
    func setupSliderViews(_ sizeSlider: UISlider, _ widthSlider: UISlider,
                          _ heightSlider: UISlider, _ rotationSlider: UISlider) {
        widthSlider.superview?.isHidden = true
        heightSlider.superview?.isHidden = true
        sizeSlider.superview?.isHidden = false
        rotationSlider.superview?.isHidden = false

        sizeSlider.value = Float(size)
        rotationSlider.value = Float(Convert.radiansToDegrees(angleInRadians: angle))
    }
}

class BluePegView: PegView {
    override init(at location: CGPoint, radius: CGFloat, angle: CGFloat) {
        super.init(at: location, radius: radius, angle: angle)
        updatePegAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updatePegAppearance() {
        if isHit {
            image = #imageLiteral(resourceName: "peg-blue-glow")
        } else {
            image = #imageLiteral(resourceName: "peg-blue")
        }
    }
}

class OrangePegView: PegView {
    override init(at location: CGPoint, radius: CGFloat, angle: CGFloat) {
        super.init(at: location, radius: radius, angle: angle)
        updatePegAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updatePegAppearance() {
        if isHit {
            image = #imageLiteral(resourceName: "peg-orange-glow")
        } else {
            image = #imageLiteral(resourceName: "peg-orange")
        }
    }
}

class GreenPegView: PegView {
    override init(at location: CGPoint, radius: CGFloat, angle: CGFloat) {
        super.init(at: location, radius: radius, angle: angle)
        updatePegAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updatePegAppearance() {
        if isHit {
            image = #imageLiteral(resourceName: "peg-green-glow")
        } else {
            image = #imageLiteral(resourceName: "peg-green")
        }
    }
}

class ZombiePegView: PegView {
    override init(at location: CGPoint, radius: CGFloat, angle: CGFloat) {
        super.init(at: location, radius: radius, angle: angle)
        updatePegAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updatePegAppearance() {
        if isHit {
            image = nil
        } else {
            image = #imageLiteral(resourceName: "ball")
        }
    }
}

class InverterPegView: PegView {
    override init(at location: CGPoint, radius: CGFloat, angle: CGFloat) {
        super.init(at: location, radius: radius, angle: angle)
        updatePegAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updatePegAppearance() {
        if isHit {
            image = nil
        } else {
            image = #imageLiteral(resourceName: "peg-inverter")
        }
    }
}
