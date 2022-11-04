//
//  ContentView
//  Collide2
// 
//  David Strehlow 8:33 PM 10/29/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import SwiftUI

struct ContentView: View {
    @StateObject var particleSystem = ParticleSystem()
    
    var body: some View {
        CollisionsView(particleSystem: particleSystem)
            .ignoresSafeArea()
            .background(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
