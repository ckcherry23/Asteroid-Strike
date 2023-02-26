//
//  GameEngine+SpicyPegs.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 26/2/23.
//

extension GameEngine {
    func handleSpicyPegs() {
        handleZombiePegs()
        handleInverterPegs()
    }

    private func handleZombiePegs() {
        let zombiePegs: [Peg] = gameboard.pegs.filter({ $0.type == .zombie && $0.isHit })
        zombiePegs.forEach({
            removePeg(peg: $0)
            setupExtraBall(location: $0.location)
        })
    }

    private func handleInverterPegs() {
        let inverterPegs: [Peg] = gameboard.pegs.filter({ $0.type == .inverter && $0.isHit })
        inverterPegs.forEach({
            removePeg(peg: $0)
            rendererDelegate?.toggleGameboardOrientation()
        })
    }
}
