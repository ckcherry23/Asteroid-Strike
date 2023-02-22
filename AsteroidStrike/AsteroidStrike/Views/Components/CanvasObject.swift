//
//  CanvasObject.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 23/1/23.
//

import UIKit

protocol CanvasObject: UIImageView, Hashable {
    var location: CGPoint { get set }
    func setAngle(newAngle: CGFloat)
    func setupSliderViews(_ sizeSlider: UISlider, _ widthSlider: UISlider,
                          _ heightSlider: UISlider, _ rotationSlider: UISlider)
}
