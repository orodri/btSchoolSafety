//
//  HomeView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/12/22.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    
    @ObservedObject private var system = System.shared
    @State private var isPresenting = false
    
    var body: some View {
        if (system.isWaitingForActivation) {
            WaitingView(isPresenting: false)
        } else if (!system.isActivated) {
            VStack {
                Spacer()
                Text("Your location is not being shared right now.")
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }){ Text("Go to settings...").underline() }
                // TODO: ^^ This button needs to be hidden when locations are set right
                Spacer()
                Text("Your app permissions are set correctly. ✅")
                Spacer()
                Button(action:{
                    isPresenting.toggle()
                    LocationTracker.shared.startTracking()
                    LocationTrackingService.shared.beginSendingNearestUpdates()
                    LocationTrackingService.shared.beginSendingPreciseLocationUpdates()
                }) {
                    Text("**Panic Button**")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 300)
                    .background(RoundedRectangle(cornerRadius: 300).fill(Color.red).shadow(radius: 3))
                                        .font(.largeTitle)
                }
                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: $isPresenting) {
                PanicSelector(isPresented: $isPresenting)
            }
        } else {
            ActiveView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
