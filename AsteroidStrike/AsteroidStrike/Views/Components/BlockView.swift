//
//  BlockView.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 21/2/23.
//

import UIKit

class BlockView: UIImageView, CanvasObject {
    var location: CGPoint?

    init(at location: CGPoint, size: CGSize) {
        let boundingBox = CGRect(origin: location, size: size)
        super.init(frame: boundingBox)
        self.location = location
        self.customize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func customize() {
        self.isUserInteractionEnabled = true
        image = UIImage(named: "block")
    }
}
