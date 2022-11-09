//
//  ContentView.swift
//  btssUtil
//
//  Created by Owen Rodriguez on 11/9/22.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @ObservedObject var beacons = Beacons.shared
    
    var body: some View {
        List(beacons.beacons.sorted(by: { Double(truncating: $0.minor) < Double(truncating: $1.minor) }),
             id: \.label) { beacon in
            HStack() {
                Text("\(beacon.major):\(beacon.minor)")
                    .lineLimit(1)
                    .allowsTightening(true)
                Spacer()
                Text(beacon.accuracy.formatted())
            }
        }
        .onAppear {
            beacons.startRanging()
        }
        .onDisappear() {
            beacons.stopRanging()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
