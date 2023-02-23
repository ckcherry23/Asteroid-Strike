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

    private(set) var radius: CGFloat
    private(set) var location: CGPoint
    private(set) var angle: CGFloat
    private(set) var type: PegType

    var physicsBody: CirclePhysicsBody
    var isHit: Bool {
        physicsBody.hitCounter > 0
    }

    var hitBox: CGPath {
        let boundingBox = CGRect.boundingBoxForCircle(center: location, radius: CGFloat(radius))
        return CGPath(ellipseIn: boundingBox, transform: nil)
    }

    init(location: CGPoint, type: PegType, radius: CGFloat = Peg.defaultRadius, angle: CGFloat = 0.0) {
        self.location = location
        self.type = type
        self.radius = radius
        self.angle = angle
        self.physicsBody = CirclePhysicsBody(radius: radius, center: location)
        self.physicsBody.isDynamic = false
        self.physicsBody.isAffectedByGravity = false
        self.physicsBody.mass = Peg.defaultMass

        if type == .green {
            physicsBody.categoryBitmask = PhysicsBodyCategory.activePowerup
        }
    }

    func copy() -> Peg {
        Peg(location: location, type: type, radius: radius, angle: angle)
    }
}

enum PegType: Codable {
    case blue
    case orange
    case green

    static let pegViewMapping: [PegType: (Peg) -> (PegView) ] = [
        .blue: { (peg) in BluePegView(at: peg.location, radius: peg.radius, angle: peg.angle) },
        .orange: { (peg) in OrangePegView(at: peg.location, radius: peg.radius, angle: peg.angle) },
        .green: { (peg) in GreenPegView(at: peg.location, radius: peg.radius, angle: peg.angle) }
    ]
}

extension Peg: Hashable {
    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs.radius == rhs.radius &&
        lhs.location == rhs.location &&
        lhs.type == rhs.type &&
        lhs.angle == rhs.angle
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(radius)
        hasher.combine(location)
        hasher.combine(type)
        hasher.combine(angle)
    }
}

extension Peg: Codable {
    private enum CodingKeys: String, CodingKey {
        case radius
        case location
        case type
        case angle
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(location: try values.decode(CGPoint.self, forKey: .location),
                  type: try values.decode(PegType.self, forKey: .type),
                  radius: try values.decode(CGFloat.self, forKey: .radius),
                  angle: try values.decode(CGFloat.self, forKey: .angle))
    }
}
