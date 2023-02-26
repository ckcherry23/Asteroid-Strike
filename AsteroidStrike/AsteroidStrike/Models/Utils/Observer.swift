//
//  Observer.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 22/2/23.
//

protocol Observer: AnyObject {
    func update()
}

protocol Observable {
    func attach(observer: Observer)
    func detach(observer: Observer)
    func notify()
}
