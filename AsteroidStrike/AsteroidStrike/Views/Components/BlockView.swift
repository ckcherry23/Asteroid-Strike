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

    init(at location: CGPoint, size: CGSize) {
        let boundingBox = CGRect.centeredRectangle(center: location, size: size)
        self.location = location
        self.size = size
        super.init(frame: boundingBox)
        self.customize()
    }

    required init?(coder: NSCoder) {
        self.location = CGPoint.zero
        self.size = CGSize.zero
        super.init(coder: coder)
    }

    func setSize(newSize: CGSize) {
        size = newSize
        frame = CGRect.centeredRectangle(center: location, size: newSize)
    }

    private func customize() {
        self.isUserInteractionEnabled = true
        image = UIImage(named: "block")
        self.contentMode = .scaleToFill
    }
}

extension BlockView {
    func setupSliderViews(_ sizeSlider: UISlider, _ widthSlider: UISlider,
                          _ heightSlider: UISlider, _ rotationSlider: UISlider) {
        widthSlider.superview?.isHidden = false
        heightSlider.superview?.isHidden = false
        sizeSlider.superview?.isHidden = true
        rotationSlider.superview?.isHidden = false

        widthSlider.value = Float(frame.width)
        heightSlider.value = Float(frame.height)
    }
}
