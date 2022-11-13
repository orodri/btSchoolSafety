//
//  ContentView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/12/22.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    var body: some View {
        VStack {
//            Text(CLLocationManager.locationServicesEnabled() ? "hello":"bye")
            Button("Panic Button") { print("Panic Button tapped!🔴")
            }.padding()
                .tint(.red)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
            Text("hold the panic button for 3 seconds to activate")
                .padding([.leading, .trailing], 50)
                .multilineTextAlignment(.center)
        }
        .padding()
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
