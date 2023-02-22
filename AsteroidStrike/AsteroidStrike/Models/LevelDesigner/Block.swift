//
//  Block.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 21/2/23.
//

import CoreGraphics

struct Block: GameboardObject {
    private static let defaultSize: CGSize = CGSize(width: 100, height: 50)
    private static let defaultMass: CGFloat = 1000

    private(set) var size: CGSize
    private(set) var location: CGPoint
    private(set) var angle: CGFloat

    var hitBox: CGPath {
        let rect = CGRect.centeredRectangle(center: location, size: size)
        var transform = CGAffineTransform(translationX: location.x, y: location.y)
            .rotated(by: angle)
            .translatedBy(x: -location.x, y: -location.y)
        return CGPath(rect: rect, transform: &transform)
    }

    var physicsBody: RectanglePhysicsBody

    init(location: CGPoint, size: CGSize = Block.defaultSize, angle: CGFloat = 0.0) {
        self.location = location
        self.size = size
        self.angle = angle
        self.physicsBody = RectanglePhysicsBody(rect: CGRect.centeredRectangle(center: location, size: size))
        self.physicsBody.isDynamic = false
        self.physicsBody.isAffectedByGravity = false
        self.physicsBody.mass = Block.defaultMass
    }

    func copy() -> Block {
        Block(location: location, size: size, angle: angle)
    }
}

extension Block: Hashable {
    static func == (lhs: Block, rhs: Block) -> Bool {
        lhs.location == rhs.location &&
        lhs.size == rhs.size &&
        lhs.angle == rhs.angle
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(location)
        hasher.combine(size.height)
        hasher.combine(size.width)
        hasher.combine(angle)
    }
}

extension Block: Codable {
    private enum CodingKeys: String, CodingKey {
        case location
        case size
        case angle
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(location: try values.decode(CGPoint.self, forKey: .location),
                  size: try values.decode(CGSize.self, forKey: .size),
                  angle: try values.decode(CGFloat.self, forKey: .angle))
    }
}
