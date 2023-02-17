//
//  PegView.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 23/1/23.
//

import UIKit

class PegView: UIImageView, CanvasObject {
    var location: CGPoint?
    var isHit: Bool = false {
        didSet {
            self.updatePegAppearance()
        }
    }

    fileprivate init(at location: CGPoint, radius: CGFloat) {
        let boundingBox = CGRect.boundingBoxForCircle(center: location, radius: radius)
        super.init(frame: boundingBox)
        self.location = location
        self.customize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func customize() {
        self.layer.cornerRadius = bounds.size.width / 2
        self.isUserInteractionEnabled = true
    }

    func updatePegAppearance() {}
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
