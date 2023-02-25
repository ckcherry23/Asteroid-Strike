//
//  GameEngine+SpicyPegs.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 26/2/23.
//

extension GameEngine {
    func handleSpicyPegs() {
        handleZombiePegs()
    }

    private func handleZombiePegs() {
        let zombiePegs: [Peg] = gameboard.pegs.filter({ $0.type == .zombie && $0.isHit })
        zombiePegs.forEach({
            removePeg(peg: $0)
            setupExtraBall(location: $0.location)
        })
    }
}
