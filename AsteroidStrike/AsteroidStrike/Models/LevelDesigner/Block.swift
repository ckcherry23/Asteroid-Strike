//
//  Block.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 21/2/23.
//

import CoreGraphics

struct Block: GameboardObject {
    private static let defaultSize: CGSize = CGSize(width: 100, height: 100)
    private static let defaultMass: CGFloat = 10

    private(set) var size: CGSize = Block.defaultSize
    private(set) var location: CGPoint

    var hitBox: CGPath {
        let rect = CGRect.centeredRectangle(center: location, size: size)
        return CGPath(rect: rect, transform: nil)
    }

    var physicsBody: RectanglePhysicsBody

    init(location: CGPoint) {
        self.location = location
        self.physicsBody = RectanglePhysicsBody(rect: CGRect.centeredRectangle(center: location, size: size))
        self.physicsBody.isDynamic = false
        self.physicsBody.isAffectedByGravity = false
        self.physicsBody.mass = Block.defaultMass
    }
}

extension Block: Hashable {
    static func == (lhs: Block, rhs: Block) -> Bool {
        lhs.location == rhs.location &&
        lhs.size == rhs.size
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(location)
        hasher.combine(size.height)
        hasher.combine(size.width)
    }
}

extension Block: Codable {
    private enum CodingKeys: String, CodingKey {
        case location
        case size
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(location: try values.decode(CGPoint.self, forKey: .location))
    }
}
