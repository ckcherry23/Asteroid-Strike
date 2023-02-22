//
//  BlockView.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 21/2/23.
//

import UIKit

class BlockView: UIImageView, CanvasObject {
    var location: CGPoint
    var size: CGSize
    var angle: CGFloat

    init(at location: CGPoint, size: CGSize, angle: CGFloat) {
        let boundingBox = CGRect.centeredRectangle(center: location, size: size)
        self.location = location
        self.size = size
        self.angle = angle
        super.init(frame: boundingBox)
        self.customize()
    }

    required init?(coder: NSCoder) {
        self.location = CGPoint.zero
        self.size = CGSize.zero
        self.angle = CGFloat.zero
        super.init(coder: coder)
    }

    func setSize(newSize: CGSize) {
        size = newSize
        frame = CGRect.centeredRectangle(center: location, size: newSize)
    }

    func setAngle(newAngle: CGFloat) {
        angle = newAngle
        self.transform = CGAffineTransform(rotationAngle: newAngle)
    }

    private func customize() {
        self.isUserInteractionEnabled = true
        image = UIImage(named: "block")
        self.contentMode = .scaleToFill
        self.transform = CGAffineTransform(rotationAngle: angle)
    }
}

extension BlockView {
    func setupSliderViews(_ sizeSlider: UISlider, _ widthSlider: UISlider,
                          _ heightSlider: UISlider, _ rotationSlider: UISlider) {
        widthSlider.superview?.isHidden = false
        heightSlider.superview?.isHidden = false
        sizeSlider.superview?.isHidden = true
        rotationSlider.superview?.isHidden = false

        widthSlider.value = Float(size.width)
        heightSlider.value = Float(size.height)
        rotationSlider.value = Float(Convert.radiansToDegrees(angleInRadians: angle))
    }
}
