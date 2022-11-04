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
            let p1 = Particle.init(x: -1, y: -1, angle: 0, speed: 0)
            p1.name = "orange"
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
            print("appended")
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
            counter += 1
        } else if angle >= .pi {
            // going up and left
            revAngle = ((1.5 * .pi) - angle) + (0.5 * .pi)
            counter += 1
        } else if angle >= 0.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (0.5 * .pi))
            counter += 1
        } else if angle >= 0 {
            revAngle = (2 * .pi) - angle
            counter += 1
        }
        return revAngle
    }
    
    func reverseAngleVWall(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        if angle >= 1.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (1.5 * .pi))
            counter += 1
        } else if angle >= .pi {
            revAngle = (1.5 * .pi) + ((1.5 * .pi) - angle)
            counter += 1
        } else if angle >= 0.5 * .pi {
            revAngle = (0.5 * .pi) - (angle - (0.5 * .pi))
            counter += 1
        } else if angle >= 0 {
            revAngle = (0.5 * .pi) + ((0.5 * .pi) - angle)
            counter += 1
        }
        return revAngle
    }
    var counter1 = 0
    public func runPriorityQueue(particleSystem: ParticleSystem) {
        var done: Bool = false
        while !done && PQ.count > 1 {
            let updateEvent = PQ[PQ.count - 1]
            // Evaluate current event, then evaluate next events.
            
//            print("PQ count is \(self.PQ.count)")
            
            if self.PQ.count == 3 {
                print("here")
            }
            
            if updateEvent.updateTime <= Date() && (updateEvent.p2 == nil || updateEvent.p1 == nil) {
                print("counter1: \(counter1)")
                counter1 += 1
                evaluateCurrentWallCollision(updateEvent)
                // Then delete the event from the queue because it's evaluated:
                PQ = deleteMinimum(PQ)
                
                evaluateNextCollisions(after:updateEvent, particleSystem: particleSystem)
            } else if updateEvent.updateTime <= Date() && updateEvent.p2 != nil{
                evaluateCurrentParticlesCollision(particleSystem, updateEvent)
                // This is a two particle collision event
                let p1 = updateEvent.p1
                
                let p2 = updateEvent.p2
                
//                updateEvent.p1.angle = reverseAngleVWall(updateEvent.p1.angle)
                
//                updateEvent.p2!.angle = reverseAngleVWall(updateEvent.p2!.angle)
//                reverseAngleVWall(updateEvent.p1.angle)
//                reverseAngleVWall(updateEvent.p2!.angle)
//                updateEvent.p2!.angle = reverseAngleVWall(updateEvent.p2!.angle)
 
                PQ = deleteMinimum(PQ)
                
                evaluateNextCollisions(after: updateEvent, particleSystem: particleSystem)
            } else {
                done = true
            }
        }
    }
    
    public func evaluateCurrentParticlesCollision(_ particleSystem: ParticleSystem, _ updateEvent: ParticleUpdateEvent) {// Since it's a wall event, there's only one particle, p1:
        var ps = particleSystem
        print("first particle Angle: \(ps.particles[0].angle)")
        print("second particle Angle: \(ps.particles[1].angle)")
        print("p1 angle: \(updateEvent.p1.angle)")
        print("p2 angle: \(updateEvent.p2!.angle)")
        let p1 = updateEvent.p1
        let p2 = updateEvent.p2
        p1.angle = reverseAngleVWall(p1.angle)
        print("first particle Angle: \(ps.particles[0].angle)")
        if let p2 = p2 {
            p2.angle = reverseAngleVWall(p2.angle)
            if p2.angle > 6.28 && p2.angle < 6.3 {
                p2.angle = 0
            }
        }
        
        print("p1 angle: \(updateEvent.p1.angle)")
        print("p2 angle: \(updateEvent.p2!.angle)")
    }
    
    public func evaluateCurrentWallCollision(_ updateEvent: ParticleUpdateEvent) {
        // Since it's a wall event, there's only one particle, p1:
        let particle = updateEvent.p1
        let xPosition = updateEvent.p1.x
        if xPosition > 0.99 {
            particle.x = 0.99
            particle.angle = reverseAngleVWall(particle.angle)
        }
        if xPosition < 0.003 {
            particle.x = 0.003
            particle.angle = reverseAngleVWall(particle.angle)
        }
    }
    
    // Evaluate all future collisions for a given particle: wall or other particles
    public func evaluateNextCollisions(after event:ParticleUpdateEvent, particleSystem: ParticleSystem) {
        // Find the next wall events for the particles in the current event:
        evaluateNextWallCollision(event.p1)
        if let eventp2 = event.p2 {
            evaluateNextWallCollision(eventp2)
        }
        
        // Find the next collision with any other particle:
        for particle in particleSystem.particles {
            let timeToHit = particle.evaluateNextParticleCollision(event.p1) ?? 0.0
            if timeToHit > 0 {
                let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
                let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
                let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
                self.insert(x: particleUpdateEvent)
            }
        }
        
        for particle in particleSystem.particles {
            if let event = event.p2 {
                let timeToHit = particle.evaluateNextParticleCollision(event) ?? 0.0
                if timeToHit > 0 {
                    let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
                    let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
                    let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
                    self.insert(x: particleUpdateEvent)
                }
            }
        }
    }
    
    public func evaluateNextWallCollision(_ particle: Particle) {
        let hTime = particle.timeUntilVertWallCollision()
        let vTime = particle.timeUntilHorizWallCollision()

        let timeToHit = (hTime < vTime ? hTime : vTime)
        if timeToHit > 0 {
            let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
            let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
            let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
            self.insert(x: particleUpdateEvent)
        }
    }
}


