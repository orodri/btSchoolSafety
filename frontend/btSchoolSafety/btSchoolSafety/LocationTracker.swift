//
//  LocationTracker.swift
//  btssUtil
//
//  Created by Owen Rodriguez on 11/9/22.
//

import CoreLocation

class LocationTracker: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var matchingUuid = CLBeaconIdentityConstraint(uuid: proximityUuid)
    private var isTracking = false
    private var shouldTrack = false
    
    static let shared = LocationTracker()
    @Published var beacons: [CLBeacon] = []
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    func startTracking() {
        shouldTrack = true
        checkAuthorizationAndTrackIfNeeded()
    }
    
    func stopTracking() {
        locationManager.stopRangingBeacons(satisfying: matchingUuid)
        shouldTrack = false
        isTracking = false
    }
    
    func checkAuthorizationAndTrackIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            if shouldTrack {
                isTracking = true
                locationManager.startRangingBeacons(satisfying: matchingUuid)
                print("started ranging beacons")
            } else {
                isTracking = false
                locationManager.stopRangingBeacons(satisfying: matchingUuid)
                print("stopped ranging beacons")
            }
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                print("authorizedWhenInUse")
                // TODO: Explain the app likely won't function properly.
            }
        default:
            print("Not authorized")
            isTracking = false
            locationManager.stopRangingBeacons(satisfying: matchingUuid)
            // TODO: Explain the app won't function properly to the user.
        }
    }
}

extension LocationTracker: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationAndTrackIfNeeded()
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        self.beacons = beacons
//        print("didRange")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        print("didFailRangingFor: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("didUpdateLocations")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error.localizedDescription)")
    }
}
