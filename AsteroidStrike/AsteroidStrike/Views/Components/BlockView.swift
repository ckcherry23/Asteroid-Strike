//
//  BlockView.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 21/2/23.
//

import UIKit

class BlockView: UIImageView, CanvasObject {
    var location: CGPoint

    init(at location: CGPoint, size: CGSize) {
        let boundingBox = CGRect.centeredRectangle(center: location, size: size)
        self.location = location
        super.init(frame: boundingBox)
        self.customize()
    }

    required init?(coder: NSCoder) {
        self.location = CGPoint.zero
        super.init(coder: coder)
    }

    private func customize() {
        self.isUserInteractionEnabled = true
        image = UIImage(named: "block")
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
