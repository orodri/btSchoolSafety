//
//  ContentView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/12/22.
//

import SwiftUI
import CoreLocation

//import LocationService

struct ContentView: View {
    
    // Configure the location manager and ask for user permission
//    func check() {
//        if (CLLocationManager.locationServicesEnabled()){
//            print("i am here")
//        } else {
//            print("no")
//        }
////        locmanager.desiredAccuracy = kCLLocationAccuracyBest
//
//        locmanager.requestWhenInUseAuthorization()
//
//    }
    
    private let locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            Text("Please set your location settings to **Always Allow** for the app to work.")
                .padding([.leading, .trailing], 25)
                .multilineTextAlignment(.center)
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
            Button(action:{}){
                Text("**Panic Button**")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 300)
                    .background(RoundedRectangle(cornerRadius: 300).fill(Color.red).shadow(radius: 3))
                    .font(.largeTitle)
            }.simultaneousGesture(LongPressGesture(minimumDuration: 3.0).onEnded({_ in
                print("holding...")
                // TODO: add implementation of sending out alerts
            }))
                .padding()
                
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
