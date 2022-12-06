//
//  Networking.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 12/3/22.
//

import Foundation
import Combine

class LocationTrackingService: NSObject, ObservableObject, URLSessionDelegate {
    private var webSocketTask: URLSessionWebSocketTask?
    private var isOpened = false
    private var subscriptions = Set<AnyCancellable>()
    private var previousNearestBeaconMinor: Int?
    
    static let shared = LocationTrackingService()
    
    private override init() {
        super.init()
        openWebSocket()
    }
    
    private func openWebSocket() {
        let url = serverWsUrl.appendingPathComponent("/ws/student")
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        isOpened = true
        
        self.receiveMessage()
    }
    
    private func receiveMessage() {
        if !isOpened {
            openWebSocket()
        }
        
        webSocketTask?.receive(completionHandler: { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let message):
                switch message {
                case .string(let messageString):
                    print(messageString)
                case .data(let data):
                    print(data.description)
                default:
                    print("Unknown type received from WebSocket")
                }
            }
            self.receiveMessage()
        })
    }
    
    private func sendNearest(_ nearest: Int?) {
        let jsonObj: [String: Any?] = [
            "anonIdentifier": System.shared.anonIdentifier,
            "nearest": nearest
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("sendNearest: jsonData serialization error")
            return
        }
        
        webSocketTask?.send(URLSessionWebSocketTask.Message.data(jsonData)) { error in
            if let error = error {
                print("Failed with Error \(error.localizedDescription)")
            }
        }
    }
    
    private func closeSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isOpened = false
    }
    
    func beginSendingNearestUpdates() {
        LocationTracker.shared.$beacons.sink() { [self] beacons in
            let beacon = beacons
                .filter { $0.accuracy > 0 } // .accuracy is -1 when undetermined which does not mean near
                .sorted { $0.accuracy < $1.accuracy } // sort by nearest
                .first
            
            var nearest: Int? = nil
            if let beacon = beacon {
                // .major/.minor are 16-bits, we'll use 32-bit ints from here
                // also we're keeping things simple and just identifying beacons with their .minor
                nearest = Int(truncating: beacon.minor)
            }
            
            if nearest != previousNearestBeaconMinor { // reduce spamming the server if the nearest hasn't changed
                self.sendNearest(nearest)
            }
            
            previousNearestBeaconMinor = nearest
        }.store(in: &subscriptions)
    }
    
    private func sendPrecise(_ annotatedBeaconsToSend: [(minor: Int, distance: Double)]) {
        let jsonObj: [AnyHashable: Any?] = [
            "anonIdentifier": System.shared.anonIdentifier,
            "beacons": annotatedBeaconsToSend.map { [ "minor": $0.minor, "distance": $0.distance ] }
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("sendPrecise: jsonData serialization error")
            return
        }
        
        webSocketTask?.send(.data(jsonData)) { error in
            if let error = error {
                print("sendPrecise failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func beginSendingPreciseLocationUpdates() {
        LocationTracker.shared.$beacons.sink() { [self] beacons in
            let beacons = beacons
                .filter { $0.accuracy > 0 }
                .map { (Int(truncating: $0.minor), $0.accuracy) }
            
            self.sendPrecise(beacons)
        }.store(in: &subscriptions)
    }
}

extension LocationTrackingService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        print("Web socket opened")
        isOpened = true
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        print("Web socket closed")
        isOpened = false
    }
}
