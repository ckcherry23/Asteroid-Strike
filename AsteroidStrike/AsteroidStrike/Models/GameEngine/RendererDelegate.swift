//
//  RendererDelegate.swift
//  AsteroidStrike
//
//  Created by Charisma Kausar on 26/2/23.
//

protocol RendererDelegate: AnyObject {
    func render()
    func isRendererAnimationComplete() -> Bool
    func toggleGameboardOrientation()
}
