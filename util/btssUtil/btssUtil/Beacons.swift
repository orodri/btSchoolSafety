//
//  Beacons.swift
//  btssUtil
//
//  Created by Owen Rodriguez on 11/9/22.
//

import CoreLocation

fileprivate let proximityUuidKey = "PROXIMITY_UUID"

class Beacons: NSObject, ObservableObject {
    static let shared = Beacons()
    private let locationManager = CLLocationManager()
    @Published var beacons: [CLBeacon] = []
    
    private var matchingUuid: CLBeaconIdentityConstraint {
        get {
            guard let uuid = Bundle.main.object(forInfoDictionaryKey: proximityUuidKey) as? String,
                  let uuid = UUID(uuidString: uuid) else {
                fatalError("\(proximityUuidKey) not set")
            }
            return CLBeaconIdentityConstraint(uuid: uuid)
        }
    }
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func startRanging() {

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startRangingBeacons(satisfying: matchingUuid)
        default:
            print("no auth")
        }
    }
    
    func stopRanging() {
        locationManager.stopRangingBeacons(satisfying: matchingUuid)
    }
}

extension Beacons: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didRange beacons: [CLBeacon],
                         satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        self.beacons = beacons
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startRangingBeacons(satisfying: matchingUuid)
        default:
            print("no auth")
        }
    }
}

extension CLBeacon {
    var label: String {
        get {
            return "\(self.uuid.uuidString):\(self.major):\(self.minor)"
        }
    }
}
