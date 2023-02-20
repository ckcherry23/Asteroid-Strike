//
//  BallView.swift
//  CoreGameplay
//
//  Created by Charisma Kausar on 5/2/23.
//

import UIKit

class BallView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func customize() {
        self.image = UIImage(named: "ball")
        self.contentMode = .scaleAspectFill
        self.layer.cornerRadius = bounds.size.width / 2
        self.layer.zPosition = ZIndices.ballView
    }
}
