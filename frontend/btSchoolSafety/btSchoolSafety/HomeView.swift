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
    private let locationManager = CLLocationManager();
    
    var body: some View {
        if (system.isWaitingForActivation) {
            WaitingView(isPresenting: false)
        } else {
            VStack {
                Spacer()
                Text("Your location is not being shared right now.")
                Button(action: {
                    switch locationManager.authorizationStatus {
                        case .notDetermined:
                            locationManager.requestWhenInUseAuthorization()
                        case .authorizedAlways, .authorizedWhenInUse:
                            print("start ranging beacons")
                //                                locationManager.startRangingBeacons(satisfying: matchingUuid)
                        default:
                            print("no auth")
                        }
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }){ Text("Go to settings...").underline() }
                // TODO: ^^ This button needs to be hidden when locations are set right
                Spacer()
                Text("Your app permissions are set correctly. ✅")
                Spacer()
                Button(action:{}) {
                    Text("**Panic Button**")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 300)
                    .background(RoundedRectangle(cornerRadius: 300).fill(Color.red).shadow(radius: 3))
                                        .font(.largeTitle)
                }.simultaneousGesture(LongPressGesture(minimumDuration: 3.0).onEnded({_ in
                    isPresenting.toggle()
                    LocationTracker.shared.startTracking()
                    LocationTrackingService.shared.beginSendingNearestUpdates()
                    LocationTrackingService.shared.beginSendingPreciseLocationUpdates()
                }))
//                .buttonStyle(.bordered)
//                .tint(.red)
//                .controlSize(.large)
                Spacer()
                Text("Hold the panic button for 3 seconds to activate.")
            }
            .padding()
            .onAppear(){
                Task {
                    await postRegister()
                }
            }
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
