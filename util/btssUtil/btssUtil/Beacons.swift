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
    
    func findLocation() -> (Double, Double){
        /*if beacons.count < 3 {
            return (-1,-1)
        }*/
        var activeBcns: [CLBeacon] = []
        for beacon in beacons{
            if beacon.accuracy != -1 {
                activeBcns.append(beacon)
            }
        }
        if activeBcns.count < 3{
            return(-1,-1)
        }
        var bcnCordinates: [(Double,Double)] = []
        for i in 0...2{
            if Double(truncating: activeBcns[i].minor) == 288 {
                if Double(truncating: activeBcns[i].major) == 924 {
                    bcnCordinates.append((-2.4,2.88))
                }
                else{
                    bcnCordinates.append((2.4,2.88))
                }
            }
            else{
                if Double(truncating: activeBcns[i].major) == 924 {
                    bcnCordinates.append((-2.4,0))
                }
                else{
                    bcnCordinates.append((2.4,0))
                }
            }
        }
        let distance1 = activeBcns[0].accuracy
        let distance2 = activeBcns[1].accuracy
        let distance3 = activeBcns[2].accuracy
        let a = -2*bcnCordinates[0].0 + 2*bcnCordinates[1].0
        let b = -2*bcnCordinates[0].1 + 2*bcnCordinates[1].1
        let c = pow(distance1,2) - pow(distance2,2) - pow(bcnCordinates[0].0,2) + pow(bcnCordinates[1].0,2) - pow(bcnCordinates[0].1,2) + pow(bcnCordinates[1].1,2)
        let d = -2*bcnCordinates[1].0 + 2*bcnCordinates[2].0
        let e = -2*bcnCordinates[1].1 + 2*bcnCordinates[2].1
        var f = pow(distance2,2) - pow(distance3,2) - pow(bcnCordinates[1].0,2)
        f = f + pow(bcnCordinates[2].0,2) - pow(bcnCordinates[1].1,2) + pow(bcnCordinates[2].1,2)
        let x = (c*e - f*b)/(e*a-b*d)
        let y = (c*d-a*f)/(b*d-a*e)
        return (x,y)
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
