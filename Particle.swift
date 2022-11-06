//
//  Particle
// 
//  David@Fastest.App 1:11 PM 10/22/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation
import UIKit

class Particle: Hashable, Equatable {
    let id = UUID()
    
    // Position
    var x: Double
    var y: Double
    // Direction, in radians. With 0/2.pi pointing to the right.
    var angle: Double
    // Velocity
    var speed: Double
    // Radius
    var radius: Double = 0.005
    var name: String = ""
    
    init(x: Double, y: Double, angle: Double, speed: Double) {
        self.x = x
        self.y = y
        self.angle = angle
        self.speed = speed
    }
    
    static func ==(lhs: Particle, rhs: Particle) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // find the time the self particle will collide with the wall.
    func timeUntilVertWallCollision() -> Double {
        let width = UIScreen.main.bounds.width
        let xPosition = self.x
        let pixelsFromLeft = xPosition * width
        let pixelsFromRight = width - (xPosition * width)
        let xVelocity = abs(xVelocity(self.speed, self.angle))
        
        // going right:
        if ( self.angle > (1.5 * .pi) && self.angle <= (2 * .pi) ) ||
            ( self.angle >= 0 && self.angle < (0.5 * .pi) ) {
            if xVelocity == 0 {
                return Double.infinity
            } else {
                return pixelsFromRight / (xVelocity * 8.4)
            }
        } else {
            if xVelocity == 0 {
                return Double.infinity
            } else {
                return pixelsFromLeft / (xVelocity * 8.4)
            }
        }
    }
    
    // find the time the self self will collide with the wall.
    func timeUntilHorizWallCollision() -> Double {
        let height = UIScreen.main.bounds.height
        let yPosition = self.y
        let distanceFromTop = yPosition * height
        let distanceFromBottom = height - (yPosition * height)
        let yVelocity = abs(yVelocity(self.speed, self.angle))
        // going down:
        if (self.angle > 0 && self.angle < .pi) {
            if yVelocity == 0 {
                return Double.infinity
            } else {
                return (distanceFromBottom) / (yVelocity * 12)
            }
        } else {
        // going up:
            if yVelocity == 0 {
                return Double.infinity
            } else {
                return distanceFromTop / (yVelocity * 12)
            }
        }
    }
    
    func evaluateNextParticleCollision(_ particle: Particle) -> Double? {
        
        // The distance between the two particles at the start, in terms of x and y:
        var xDist = (self.x - particle.x)
        let yDist = particle.y - self.y

        // The difference in speeds between the two particles, in terms of x and y.
        // Test this: The two velocity vectors need to be opposite each other in order for the particles to collide?
        // Not true. One can catch up to another from behind. Consider the two cases:
        // 1. Two particles are headed directly toward each other with a y component of 0 and each with an x velocity of 20 or -20. In that case, starting at 0 and 1, they will hit each other at 0.5 with a combined velocity of 40.
        // How to calculate this? The point in the middle, where they meet, is distance x = 0.5.
        // They have to meet at the same time.
        // The actual time when they meed is
        
        let width = UIScreen.main.bounds.width
        let xPosition = self.x
        let pixelsFromLeft = xPosition * width
        let xVelocity1 = (xVelocity(self.speed, self.angle)) // in units per second
        let testxVelocity1 = xVelocity(self.speed, self.angle)
        let timeToHit = (0.5 * width) / (xVelocity1 * 8.4)
        // about 2.4
        xDist = xDist * width
        
        let test1 = xVelocity(particle.speed, particle.angle)
        let test2 = xVelocity(self.speed, self.angle)
        
        var xVeloDiff = (xVelocity(self.speed, self.angle) * 8.4) - (xVelocity(particle.speed, particle.angle) * 8.4)
        let yVeloDiff = yVelocity(particle.speed, particle.angle) - yVelocity(self.speed, self.angle)
        
        var netVector = xDist * xVeloDiff + yDist * yVeloDiff
        
        if netVector > 0 {
            return -1
        }

        
        // netVector is m*m / s
        // sum of velocities squared is m*m/s*s
        // sum of distances squared is m*m
        let sumOfVelocitiesSquared = ((xVeloDiff ) * (xVeloDiff )) + (yVeloDiff * yVeloDiff)
        let sumOfDistancesSquared = (xDist * xDist) + (yDist * yDist)
    
        _ = calculateRadius()

        let twoRadiuses = 2.0// * 0.2
        
        let d = (netVector * netVector) - sumOfVelocitiesSquared * (sumOfDistancesSquared - twoRadiuses * twoRadiuses)
        // = m*m*m*m / s*s - m*m/s*s * (m*m) = m*m*m*m / s*s
        if d < 0 {
            return -1
        }
        // sqrt d is m*m / s
        let collision = abs((netVector + sqrt(d)) / (sumOfVelocitiesSquared))
       // collision is mm/s / mm/ss = mmss / smm = s
        

        if collision > 0 {
            return collision
        }
        return nil
    }
    
    func calculateRadius() -> Double {
        let screenPixels = UIScreen.main.bounds.size.width
        let pictureWidth = 40.0
        return pictureWidth / screenPixels
    }

    func yVelocity(_ speed: Double, _ radians: Double) -> Double {
        var yVelocity: Double = 0
        // The cos of 80 degrees is 0.1736
        // going down:
        if ( (radians > 0)  && (radians < .pi) ) {
            yVelocity = sin(radians) * speed
        } else {
            yVelocity = sin(radians) * speed
        }
        if yVelocity < 0.0001 {
            yVelocity = 0.0
        }
        return yVelocity
    }
    
    func xVelocity(_ speed: Double, _ radians: Double) -> Double {
        var xVelocity: Double = 0
        // going right:
        if ( (radians > (1.5 * .pi))  && (radians <= (2.0 * .pi)) ) ||
            ( (radians >= 0) && (radians < (0.5 * .pi)) ) {
            xVelocity = cos(radians) * speed
            print("xVelocity: \(xVelocity)")
        } else if ( radians > (0.5 * .pi)  && (radians < (1.5 * .pi)) ) {
            xVelocity = cos(radians) * speed
            print("xVelocity: \(xVelocity)")
        }
        return xVelocity
    }
}
