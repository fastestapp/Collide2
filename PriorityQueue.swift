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
            let p1 = Particle.init(x: -1, y: -1, angle: 0, speed: 0, name: "Orange", particleIndex: -1)
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
        }
    }
    
    // If there's already an event in the queue with the particle in question, and the existing event will occur sooner, then it's a preexisting event
    private func checkPreexisting(x: ParticleUpdateEvent) -> Bool {
        var tempPQ = PQ
        if x.p2 == nil {
            for (index, event) in PQ.reversed().enumerated() {
                if event.p1 == x.p1 || event.p2 == x.p1 {
                    if event.updateTime < x.updateTime {
                        return true
                    } else if index != PQ.count {
                        tempPQ.remove(at: PQ.count - index - 1)
                    }
                }
            }
        }
        
        if x.p2 != nil {
            for (index, event) in PQ.reversed().enumerated() {
                if event.p1 == x.p2 || event.p1 == x.p1 || event.p2 == x.p2 || event.p2 == x.p1 {
                    if event.updateTime < x.updateTime {
                        return true
                    } else if index != PQ.count {
                        tempPQ.remove(at: PQ.count - index - 1)
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
    
    // A function that reverses angle assuming that the particles hit on center.
    func reverseAngleOnCollision(_ updateEvent: ParticleUpdateEvent) -> (Double, Double) {
        var revAngleP1: Double = 0.0
        var revAngleP2: Double = 0.0
        let angle1 = updateEvent.p1.angle
        let angle2 = updateEvent.p2?.angle ?? 0.0
        let angleDiff = abs(angle1 - angle2)
        
        if angle1 < angle2 {
            revAngleP1 = angle1 + angleDiff
            revAngleP2 = angle2 - angleDiff
        } else {
            revAngleP1 = angle1 - angleDiff
            revAngleP2 = angle2 + angleDiff
        }
       
        revAngleP1 = reduceAngles(revAngleP1)
        revAngleP2 = reduceAngles(revAngleP2)
        return (revAngleP1, revAngleP2)
    }
    
    func reduceAngles(_ radians: Double) -> Double {
        if radians < 2 * .pi {
            return radians
        } else if radians >= (2 * .pi) && radians < (4 * .pi) {
            return radians - (2 * .pi)
        } else {
            fatalError("too many rads")
        }
    }
    
    public func runPriorityQueue(particleSystem: ParticleSystem) {
        var done: Bool = false
        var updateEvent: ParticleUpdateEvent = PQ[PQ.count - 1]
        var eventOccurred = false
//        let beforeCount = PQ.count
        
        while !done && PQ.count > 1 {
            updateEvent = PQ[PQ.count - 1]
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
//        let afterCount = PQ.count
//        if afterCount < beforeCount {
//            print("the number updated this cycle = \(beforeCount - afterCount)")
//        }
        
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
                // If the two particles are not two that just hit each other, then they are free to hit each other again,
                // so clear the lastHitParticle values:
                clearLastHitParticles(particle, nil, particleSystem: particleSystem)
                let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
                let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
                let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate, wall: wall)
                self.insert(x: particleUpdateEvent)
            }
        }
        
        // Find all the particle collisions:
        for i in 0..<particles.count {
            for j in 0..<particles.count {
                let p1 = particles[i]
                let p2 = particles[j]
                let name1 = p1.name
                let name2 = p2.name
                if i != j {
                    
                    
                    
                    // Only evaluate a collision if the two particles are not two that just hit each other
                    if !checkLastHitParticle(p1, p2) {
                        if (name2 == "red" && name1 == "green") || (name1 == "red" && name2 == "green") {
//                            print("r & g count: \(counter4)")
                            
                            if counter4 == 4 {
//                                print("here")
                                counter4 += 1
                            }
                        }
                        
                        
                        let timeToHit = p1.evaluateNextParticleCollision(p2)
                        
                        if let timeToHit = timeToHit, timeToHit > 0 {
                            
                            // If the two particles are not two that just hit each other, then they are free to hit each other again,
                            // so clear the lastHitParticle values:
                            clearLastHitParticles(p1, p2, particleSystem: particleSystem)
                            
                            if (name2 == "red" && name1 == "green") || (name1 == "red" && name2 == "green") {
//                                print("r & g count: \(counter4)")
                                counter4 += 1
                            }
                            
                            p1.lastHitParticle = p2.particleIndex
                            p2.lastHitParticle = p1.particleIndex
                            let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
                            let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
                            let particleUpdateEvent = ParticleUpdateEvent(P1: p1, P2: p2, updateTime: updateDate)
                            self.insert(x: particleUpdateEvent)
                        }
                    }
                }
            }
        }
    }
    
    var counter4 = 1
    // if the two particles just hit each other, return true:
    public func checkLastHitParticle(_ p1: Particle, _ p2: Particle) -> Bool {
        if p1.lastHitParticle == p2.particleIndex || p1.particleIndex == p2.lastHitParticle {
            return true
        }
        return false
    }
    
    // if the two particles just hit each other, return true.
    // The particle might have just hit a wall and then p2 will be nil
    public func clearLastHitParticles(_ p1: Particle, _ p2: Particle? = nil, particleSystem: ParticleSystem) {
        
        if let hitP1 = p1.lastHitParticle {
            particleSystem.particles[hitP1].lastHitParticle = nil
            p1.lastHitParticle = nil
        }
        
        if let p2 = p2, let hitP2 = p2.lastHitParticle {
            particleSystem.particles[hitP2].lastHitParticle = nil
            p2.lastHitParticle = nil
        }
    }
    
    public func evaluateCurrentParticlesCollision(_ particleSystem: ParticleSystem, _ updateEvent: ParticleUpdateEvent) {
        let p1 = updateEvent.p1
        if let p2 = updateEvent.p2 {
            (p1.angle, p2.angle) = reverseAngleOnCollision(updateEvent)
        }
    }
    
    public func evaluateCurrentWallCollision(_ updateEvent: ParticleUpdateEvent) {
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


