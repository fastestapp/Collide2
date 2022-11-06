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
    var particleCount = 2
    let image = Image("disk")
    let image2 = Image("disk2")
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
        if counter == 0 {
            angleDegrees = 0.0 //Double.random(in: 270...360) + Double.random(in: -angleRange / 2...angleRange / 2)
            counter += 1
        } else if counter == 1 {
            angleDegrees = 180.0 //Double.random(in: 270...360) + Double.random(in: -angleRange / 2...angleRange / 2)
        }
        let angleRadians = angleDegrees * .pi / 180
        var x: Double = 0
        if pCounter == 0 {
            x = 0.0
        } else {
            x = 1.0
        }
        return Particle (
            x: x,
            y: 0.5, //Double.random(in: 0...1),
            angle: angleRadians,
            speed: 20
        )
    }
    
}

