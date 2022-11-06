//
//  ParticleSystem
// 
//  David@Fastest.App 1:18 PM 10/22/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import SwiftUI

class ParticleSystem: ObservableObject {
    var particleCount = 4
    var particles = Array<Particle>()
    var lastUpdate = Date()
    var lastCreationDate = Date()
    var priorityQueue = PriorityQueue.shared
    var didInitialQuadratic = false
    var didInitialBounceCheck = false
    
    var xPosition = 50.0
    var yPosition = 0.0
    
    var angle = 80.0
    var angleRange = 180.0
    
    var speed = 20.0
    
    func update(date: Date) {
        let elapsedTime = date.timeIntervalSince1970 - lastUpdate.timeIntervalSince1970
        lastUpdate = date
        
        // Create the particles or add them to maintain. However, if it's working, none should get lost:
        var pCounter = 0
        while particles.count < particleCount {
            particles.append(createParticle(pCounter))
            pCounter += 1
            lastCreationDate = date
        }
        
        if !didInitialBounceCheck {
            priorityQueue.evaluateNextCollisions(particleSystem: self)
            didInitialBounceCheck = true
        }
        
        // Update all the positions.
        for particle in particles {
            particle.x += cos(particle.angle) * particle.speed / 100 * elapsedTime
            particle.y += sin(particle.angle) * particle.speed / 100 * elapsedTime
        }
        
        // Update events from the PriorityQueue.
        priorityQueue.runPriorityQueue(particleSystem: self)
    }
    
    var counter = 0
    private func createParticle(_ pCounter: Int) -> Particle {
        var angleDegrees = 0.0
        var x: Double = 0
        var y: Double = 0
        var name: String = ""
        var speed: Double = Double.random(in: 10...30)
        if pCounter%4 == 0 {
            angleDegrees = 45 //Double.random(in: 270...360) + Double.random(in: -angleRange / 2...angleRange / 2)
            x = 0.0
            y = 0.0
            name = "green"
            speed = 20//Double.random(in: 10...30)
        }
        else if pCounter%4 == 1 {
            angleDegrees = 315 //Double.random(in: 100...260) + Double.random(in: -angleRange / 2...angleRange / 2)
            x = 0.0
            y = 1.0
            name = "yellow"
            speed = 20//Double.random(in: 10...30)
        } else if pCounter%4 == 2 {
            angleDegrees = 90.0 //Double.random(in: 270...360) + Double.random(in: -angleRange / 2...angleRange / 2)
            x = 0.5
            y = 0.0
            name = "red"
            speed = 10//Double.random(in: 10...30)
        } else if pCounter%4 == 3 {
            angleDegrees = 270.0 //Double.random(in: 270...360) + Double.random(in: -angleRange / 2...angleRange / 2)
            x = 0.5
            y = 1.0
            name = "blue"
            speed = 10//Double.random(in: 10...30)
        }
        
        let angleRadians = angleDegrees * .pi / 180
        
        return Particle (
            x: x,
            y: y, //Double.random(in: 0...1),
            angle: angleRadians,
            speed: speed, //Double.random(in: 10...30),
            name: name
        )
    }
    
}

