//
//  David@Fastest.App 7:58 PM 9/3/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation

class PriorityQueue {
    
    static let shared = PriorityQueue()
    var PQ = [ParticleUpdateEvent]()
    let maxPQSize = 200
    
    // Add a new value to the Priority Queue and delete the maximum value if the size of the Priority Queue exceeds the max.
    // This amounts to deleting the updateEvent that is the furthest away from now to occur:
    public func insert<T: Comparable>(x: T) where T: ParticleUpdateEvent {
        if PQ.count == 0 {
            // Make a placeholder update event for index zero; something we must do because Priority Queues start at index 1:
            let p1 = Particle.init(x: -1, y: -1, angle: 0, speed: 0, name: "Orange")
            PQ.append(ParticleUpdateEvent.init(P1: p1, P2: nil, updateTime: Date()))
        }
        
        if PQ.count < 2 {
            PQ.append(x)
        } else if !checkPreexisting(x: x) {
            PQ.append(x)
            PQ = swim(PQ, PQ.count - 1)
            if PQ.count > maxPQSize {
                PQ = deleteMaximum(PQ)
            }
//            print("appended")
        } else {
            print("preexisting")
        }
    }
    
    // If there's already an event in the queue with the particle in question, and the existing event will occur sooner, then it's a preexisting event, and return true
    private func checkPreexisting(x: ParticleUpdateEvent) -> Bool {
        // Consider incoming update event with one particle;
        // compare it to all the existing events with one or two particles.
        // If an existing event occurs earlier, we don't want to append, so we return true.
        // If an existing event occurs later, we want to get rid of it and keep traversing up the PQ
        var tempPQ = PQ
        if x.p2 == nil {
            for (index, event) in PQ.reversed().enumerated() {
                if event.p1 == x.p1 || event.p2 == x.p1 {
                    if event.updateTime < x.updateTime {
                        return true
                    } else {
                        if index != PQ.count {
                            tempPQ.remove(at: PQ.count - index - 1)
                        } else {
                            print("")
                        }
                    }
                }
            }
        }
        
        
        if x.p2 != nil {
            for (index, event) in PQ.reversed().enumerated() {
                if event.p1 == x.p2 || event.p1 == x.p1 || event.p2 == x.p2 || event.p2 == x.p1 {
                    if event.updateTime < x.updateTime {
                        return true
                    } else {
                        if index != PQ.count {
                            tempPQ.remove(at: PQ.count - index - 1)
                        } else {
                            print("")
                        }
                    }
                }
            }
        }
        PQ = tempPQ
        
        return false
    }
    
    private func swim(_ arr: [ParticleUpdateEvent], _ i: Int) -> [ParticleUpdateEvent] {
        var k = i
        var a = arr
        while k > 1 && (a[k - 1] < a[k]) {
            a = exchange(a, i: k, j: k - 1)
            k = k - 1
        }
        return a
    }
    
    private func sink<T: Comparable>(_ arr: [T], _ i: Int) -> [T] {
        var a = arr
        var k = i
        let n = a.count - 1
        while 2*k < n {
            var j = 2*k
            if j < n && a[j] < a[j+1] {
                j += 1
            }
            if a[k] >= a[j] {
                break
            }
            a = exchange(a, i: k, j: j)
            k = j
        }
        return a
    }
    
    public func deleteMaximum<T: Comparable>(_ arr: [T]) -> [T] {
        var a = arr
        let n = a.count - 1
        a = sink(a, 1)
        if n != 0 {
            a.remove(at: n)
        }
        return a
    }
    
    public func deleteMinimum<T: Comparable>(_ arr: [T]) -> [T] {
        var a = arr
        let n = a.count - 1
        if n != 0 {
            a.remove(at: n)
        }
        return a
    }
    
    public func exchange<T: Comparable>(_ arr: [T], i: Int, j: Int) -> [T] {
        var a = arr
        let temp = a[i]
        a[i] = a[j]
        a[j] = temp
        return a
    }
    
    public func exchangeWithEnd(a1: [ParticleUpdateEvent], s1: Int) -> [ParticleUpdateEvent] {
        var a = a1
        let temp = a[s1]
        a[s1] = a[a.count - 1]
        a[a.count - 1] = temp
        return a
    }
    
    var counter = 0
    
    func reverseAngleHWall(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        if angle >= 1.5 * .pi {
            revAngle = (2 * .pi)  - angle
        } else if angle >= .pi {
            revAngle = ((1.5 * .pi) - angle) + (0.5 * .pi)
        } else if angle >= 0.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (0.5 * .pi))
        } else if angle >= 0 {
            revAngle = (2 * .pi) - angle
        }
        return revAngle
    }
    
    func reverseAngleVWall(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        if angle >= 1.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (1.5 * .pi))
        } else if angle >= .pi {
            revAngle = (1.5 * .pi) + ((1.5 * .pi) - angle)
        } else if angle >= 0.5 * .pi {
            revAngle = (0.5 * .pi) - (angle - (0.5 * .pi))
        } else if angle >= 0 {
            revAngle = (0.5 * .pi) + ((0.5 * .pi) - angle)
        }
        return revAngle
    }
    
    func reverseAngle(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        
        if angle >= 0 && angle < .pi {
            revAngle = angle + .pi
        } else if angle >= .pi && angle <= 2 * .pi {
            revAngle = angle - .pi
        } else if angle == 2 * .pi {
            revAngle = .pi
        }
        
        return revAngle
    }
    
    // A function that reverses angle assuming that the particles hit on center.
    // And they must be moving toward one another, of course.
    // So if we have a p1 angle of 190 \ and a p2 angle of 290 / then p1 must be on the right going
    // up to the left and p2 must be on the left going up to the right. Otherwise they wouldn't collide.
    func reverseAngleOnCollision(_ updateEvent: ParticleUpdateEvent) -> (Double, Double) {
        var revAngleP1: Double = 0.0
        var revAngleP2: Double = 0.0
        var angle1 = updateEvent.p1.angle
        var angle2 = updateEvent.p2?.angle ?? 0.0
        let o = 1.5 * .pi //270
        let t = (3.0 * .pi) //540
        
        // Case where both are going up; angle2 up and left; angle1 up and right:
        if (angle2 >= .pi && angle2 <= 1.5 * .pi) &&
            (angle1 >= 1.5 * .pi && angle1 <= 2 * .pi) {
            revAngleP2 = (3.0 * .pi) - angle2
            revAngleP1 = (3.0 * .pi) - angle1
        }
        
        // Case where both are going up; angle1 up and left; angle2 up and right:
        else if (angle1 >= .pi && angle1 <= 1.5 * .pi) &&
            (angle2 >= 1.5 * .pi && angle2 <= 2 * .pi) {
            revAngleP2 = (3.0 * .pi) - angle2
            revAngleP1 = (3.0 * .pi) - angle1
        }
        
        // Case where both are going down; angle2 down and left; angle1 down and right:
        else if (angle2 >= 0.5 * .pi && angle2 <= .pi) &&
            (angle1 >= 0.0 && angle1 <= 0.5 * .pi) {
            revAngleP2 = .pi - angle2
            revAngleP1 = .pi - angle1
        }
        
        // Case where both are going down; angle1 down and left; angle2 down and right:
        else if (angle1 >= 0.5 * .pi && angle1 <= .pi) &&
                    (angle2 >= 0.0 && angle2 <= 0.5 * .pi) {
            revAngleP2 = .pi - angle2
            revAngleP1 = .pi - angle1
        }
        
        // Case where both are going left; angle2 left and down; angle1 left and up:
        else if (angle2 >= 0.5 * .pi && angle2 <= .pi) &&
                    (angle1 >= .pi && angle1 <= 1.5 * .pi) {
            revAngleP2 = (2 * .pi) - angle2
            revAngleP1 = (2 * .pi) - angle1
        }
        
        // Case where both are going left; angle1 left and down; angle2 left and up:
        else if (angle1 >= 0.5 * .pi && angle1 <= .pi) &&
                    (angle2 >= .pi && angle2 <= 1.5 * .pi) {
            revAngleP2 = (2 * .pi) - angle2
            revAngleP1 = (2 * .pi) - angle1
        }
        
        // Case where both are going right; angle2 right and down; angle1 right and up:
        else if (angle2 >= 0 && angle2 <= 0.5 * .pi) &&
                    (angle1 >= 1.5 * .pi && angle1 <= 2 * .pi) {
            revAngleP2 = (2 * .pi) - angle2
            revAngleP1 = (2 * .pi) - angle2
        }
        
        // Case where both are going right; angle1 right and down; angle2 right and up:
        else if (angle1 >= 0 && angle1 <= 0.5 * .pi) &&
                    (angle2 >= 1.5 * .pi && angle2 <= 2 * .pi) {
            revAngleP1 = (2 * .pi) - angle1
            revAngleP2 = (2 * .pi) - angle2
        }
        
        // Handle the same directions next:

        return (revAngleP1, revAngleP2)
    }
    
    var counter1 = 0
    public func runPriorityQueue(particleSystem: ParticleSystem) {
        var done: Bool = false
        var updateEvent: ParticleUpdateEvent = PQ[PQ.count - 1]
        var eventOccurred = false
        
        while !done && PQ.count > 1 {
            updateEvent = PQ[PQ.count - 1]
            // Evaluate current event, then evaluate next events.
            
            if updateEvent.updateTime <= Date() && updateEvent.p2 == nil {
                evaluateCurrentWallCollision(updateEvent)
                PQ = deleteMinimum(PQ)
                eventOccurred = true
            } else if updateEvent.updateTime <= Date() && updateEvent.p2 != nil {
                evaluateCurrentParticlesCollision(particleSystem, updateEvent)
                PQ = deleteMinimum(PQ)
                eventOccurred = true
            } else {
                done = true
            }
        }
        
        if eventOccurred && ( done || PQ.count == 1) {
            evaluateNextCollisions(particleSystem: particleSystem)
            eventOccurred = false
        }
    }
    
    // Evaluate all future collisions for a given particle: wall or other particles
    public func evaluateNextCollisions(particleSystem: ParticleSystem) {
        
        let particles = particleSystem.particles
        // Find all the wall collisions:
        for particle in particles {
            let vTime = particle.timeUntilVertWallCollision()
            let hTime = particle.timeUntilHorizWallCollision()
            var timeToHit: Double = 0.0
            var wall: Wall
            
            if vTime < Double.infinity && hTime < Double.infinity {
                timeToHit = hTime < vTime ? hTime : vTime
                wall = hTime < vTime ? Wall.h : Wall.v
            } else if vTime < Double.infinity {
                timeToHit = vTime
                wall = Wall.v
            } else {
                timeToHit = hTime
                wall = Wall.h
            }
            if timeToHit > 0 {
                let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
                let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
                let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate, wall: wall)
                self.insert(x: particleUpdateEvent)
            }
        }
        
        print("1: \(PQ.map {$0.updateTime.timeIntervalSinceReferenceDate})")
        
        // Find all the particle collisions:
        for i in 0..<particles.count {
            for j in 0..<particles.count {
                let p1 = particles[i]
                let p2 = particles[j]
                if i != j {
                    let timeToHit = p1.evaluateNextParticleCollision(p2)
                    if let timeToHit = timeToHit, timeToHit > 0 {
                        let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
                        let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
                        let particleUpdateEvent = ParticleUpdateEvent(P1: p1, P2: p2, updateTime: updateDate)
                        self.insert(x: particleUpdateEvent)
                    }
                }
            }
        }
        
        print("2: \(PQ.map {$0.updateTime.timeIntervalSinceReferenceDate})")
        var test = 1
    }
    
    public func evaluateCurrentParticlesCollision(_ particleSystem: ParticleSystem, _ updateEvent: ParticleUpdateEvent) {// Since it's a wall event, there's only one particle, p1:
        var ps = particleSystem
        let p1 = updateEvent.p1
        if let p2 = updateEvent.p2 {
            (p1.angle, p2.angle) = reverseAngleOnCollision(updateEvent)
//            if let p2 = p2 {
//                p2.angle = reverseAngle(p2.angle)
//                if p2.angle > 6.28 && p2.angle < 6.3 {
//                    p2.angle = 0
//                }
//            }
        }
    }
    
    public func evaluateCurrentWallCollision(_ updateEvent: ParticleUpdateEvent) {
        // Since it's a wall event, there's only one particle, p1:
        let particle = updateEvent.p1
        let xPosition = updateEvent.p1.x
        let yPosition = updateEvent.p1.y
        // Deal with the edge cases:
        if xPosition > 0.99 {
            particle.x = 0.99
            particle.angle = reverseAngleVWall(particle.angle)
            return
        }
        if xPosition < 0.003 {
            particle.x = 0.003
            particle.angle = reverseAngleVWall(particle.angle)
            return
        }
        if yPosition > 0.99 {
            particle.y = 0.99
            particle.angle = reverseAngleHWall(particle.angle)
            return
        }
        if yPosition < 0.003 {
            particle.y = 0.003
            particle.angle = reverseAngleHWall(particle.angle)
            return
        }
        if updateEvent.wall == Wall.h {
            particle.angle = reverseAngleHWall(particle.angle)
            return
        }
        if updateEvent.wall == Wall.v {
            particle.angle = reverseAngleVWall(particle.angle)
            return
        }
    }
}


