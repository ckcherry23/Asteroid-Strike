//
//  Peg.swift
//  LevelDesigner
//
//  Created by Charisma Kausar on 22/1/23.
//

import CoreGraphics

struct Peg: GameboardObject {
    private static let defaultRadius: CGFloat = 25
    private static let defaultMass: CGFloat = 10

    private(set) var radius: CGFloat = Peg.defaultRadius
    private(set) var location: CGPoint
    private(set) var color: PegColor

    var physicsBody: PhysicsBody
    var isHit: Bool {
        physicsBody.hitCounter > 0
    }

    var hitBox: CGPath {
        let boundingBox = CGRect.boundingBoxForCircle(center: location, radius: CGFloat(radius))
        return CGPath(ellipseIn: boundingBox, transform: nil)
    }

    init(location: CGPoint, color: PegColor) {
        self.location = location
        self.color = color
        self.physicsBody = CirclePhysicsBody(radius: radius, center: location)
        self.physicsBody.isDynamic = false
        self.physicsBody.isAffectedByGravity = false
        self.physicsBody.mass = Peg.defaultMass
    }

    func isOverlapping(gameboardObject: GameboardObject) -> Bool {
        self.hitBox.intersects(gameboardObject.hitBox)
    }

    func isWithin(path: CGPath) -> Bool {
        self.hitBox.subtracting(path).isEmpty
    }
}

enum PegColor: Codable {
    case blue
    case orange
}

extension Peg: Hashable {
    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs.radius == rhs.radius &&
        lhs.location == rhs.location &&
        lhs.color == rhs.color
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(radius)
        hasher.combine(location)
        hasher.combine(color)
    }
}

extension Peg: Codable {
    private enum CodingKeys: String, CodingKey {
        case radius
        case location
        case color
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(location: try values.decode(CGPoint.self, forKey: .location),
                  color: try values.decode(PegColor.self, forKey: .color))
    }
}
