//
//  ParticleUpdateEvent
//  Collisions
// 
//  David@Fastest.App 8:06 PM 10/23/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation

enum Wall: Int {
    case h
    case v
}

public class ParticleUpdateEvent: Comparable {
    var p1: Particle
    var p2: Particle?
    var updateTime: Date
    var wall: Wall = Wall.h
    
    // If one of the two particles is nil, then the event is that of hitting a wall
    init(P1 particle1: Particle, P2 particle2: Particle? = nil, updateTime: Date, wall: Wall = Wall.h) {
        self.p1 = particle1
        self.p2 = particle2
        self.updateTime = updateTime
        self.wall = wall
    }
    
    public static func == (lhs: ParticleUpdateEvent, rhs: ParticleUpdateEvent) -> Bool {
        lhs.updateTime == rhs.updateTime
    }
    
    public static func < (lhs: ParticleUpdateEvent, rhs: ParticleUpdateEvent) -> Bool {
        lhs.updateTime < rhs.updateTime
    }
}
