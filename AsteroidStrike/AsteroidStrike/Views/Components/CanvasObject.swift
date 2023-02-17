//
//  CanvasObject.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 23/1/23.
//

import UIKit

protocol CanvasObject: UIImageView, Hashable {
    var location: CGPoint? { get }
}
