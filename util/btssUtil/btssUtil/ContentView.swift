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
        VStack {
            Button("Settings...") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            List(beacons.beacons.sorted(by: { ($0.accuracy) < ($1.accuracy) }),
                 id: \.label) { beacon in
                HStack() {
                    Text("\(beacon.major):\(beacon.minor)")
                        .lineLimit(1)
                        .allowsTightening(true)
                    Spacer()
                    Text(beacon.accuracy.formatted())
                }
                var (_,_) = beacons.findLocation()
            }

            .onAppear {
                beacons.startRanging()
                /*for i in 1...100000{
                    
                }*/
            }
            .onDisappear() {
                beacons.stopRanging()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
