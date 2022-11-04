//
//  CollisionsView
//  Collisions
// 
//  David@Fastest.App 7:49 PM 10/23/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation
import SwiftUI

struct CollisionsView: View {
    var particleSystem: ParticleSystem
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                particleSystem.update(date: timeline.date)
                let baseTransform = context.transform
                
                var counter = 0
                for particle in particleSystem.particles {
                    let xPos = particle.x * size.width
                    let yPos = particle.y * size.height
                    
                    context.translateBy(x: xPos, y: yPos)
                    if counter == 0 {
                        particle.name = "red"
                        context.draw(particleSystem.image, at: .zero)
                    } else {
                        particle.name = "blue"
                        context.draw(particleSystem.image2, at: .zero)
                    }
                    context.transform = baseTransform
                    counter += 1
                }
            }
        }
    }
}
