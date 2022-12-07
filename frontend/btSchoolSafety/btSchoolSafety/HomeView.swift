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
        if (system.isActivated) {
            ActiveView()
        } else if (system.isWaitingForActivation) {
            WaitingView(isPresenting: false)
        } else {
            let locationManager = CLLocationManager()
            var shouldHide = (locationManager.authorizationStatus == .authorizedAlways)
            VStack {
                Spacer()
                Text("Your location is not being shared right now.")
                    .opacity(shouldHide ? 0 : 1)
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }){ Text("Go to settings...").underline() }
                    .opacity(shouldHide ? 0 : 1)
                Spacer()
                Text("Your app permissions are set correctly. ✅").opacity(shouldHide ? 1 : 0)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
