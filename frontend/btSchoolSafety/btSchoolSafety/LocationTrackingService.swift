//
//  Networking.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 12/3/22.
//  Shout out to: https://stackoverflow.com/a/69784743
//

import Foundation
import Combine

class LocationTrackingService: NSObject, ObservableObject, URLSessionDelegate {
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    private var isAttemptingReconnect = false
    private var reconnectTimer: Timer?
    private var untilNextAttempt = TimeInterval(1)
    private var maxTimeToWaitBeforeNextAttempt = TimeInterval(8)
    private var subscriptions = Set<AnyCancellable>()
    private var previousNearestBeaconMinor: Int?
    
    static let shared = LocationTrackingService()
    
    private override init() {
        super.init()
        connect()
    }
    
    private func connect() {
        let url = serverWsUrl.appendingPathComponent("/ws/student")
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        print("connecting to \(url)")
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        isConnected = true
        isAttemptingReconnect = false
        
        self.registerMessageReceiver()
    }
    
    private func registerMessageReceiver() {
        webSocketTask?.receive(completionHandler: { result in
            switch result {
            case .failure(let error as NSError):
                print("receiveMessage: failure [\(error.domain):\(error.code)]")
                
            case .success(let message):
                switch message {
                case .string(let messageString):
                    print(messageString)
                case .data(let data):
                    print(data.description)
                default:
                    print("Unknown type received from WebSocket")
                }
                // Apple has this weird quirk where this completionHandler
                // is unregistered every time it fires so we have to re-register
                self.registerMessageReceiver()
            }
        })
    }
    
    private func sendChat(_ chat_content: String?){
        let jsonObj: [String: Any?] = [
            "anonIdentifier": System.shared.anonIdentifier,
            "chat_content": chat_content
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("sendChat: jsonData serialization error")
            return
        }
        webSocketTask?.send(.data(jsonData), completionHandler: handleError)

    }
    
    func beginSendChat(text: String?){
        sendChat(text)
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
        
        webSocketTask?.send(.data(jsonData), completionHandler: handleError)
    }
    
    private func closeConnection() {
        print("closeConnection")
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func beginSendingNearestUpdates() {
        LocationTracker.shared.$beacons.sink() { [self] beacons in
            if (!isConnected) {
                return
            }
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
        
        webSocketTask?.send(.data(jsonData), completionHandler: handleError)
    }
    
    func beginSendingPreciseLocationUpdates() {
        LocationTracker.shared.$beacons.sink() { [self] beacons in
            if (!isConnected) {
                return
            }
            let beacons = beacons
                .filter { $0.accuracy > 0 }
                .map { (Int(truncating: $0.minor), $0.accuracy) }
            
            self.sendPrecise(beacons)
        }.store(in: &subscriptions)
    }
    
    private func handleError(_ error: Error?) {
        guard let error = error as NSError? else {
            return
        }
        
        func printHandledError(_ error: NSError) {
            print("Handling error [\(error.domain):\(error.code)]")
        }
        
        func printUnhandledError(_ error: NSError) {
            print("Unhandled error [\(error.domain):\(error.code)] \(error.localizedDescription)")
        }
        
        switch error.domain {
        case NSPOSIXErrorDomain:
            switch Int32(error.code) {
            case ENOTCONN, ECONNRESET, ETIMEDOUT: // These are defined in errno.h
                printHandledError(error)
            default:
                printUnhandledError(error)
            }
        case NSURLErrorDomain: // These are defined in NSURLError.h
            switch error.code {
            case NSURLErrorCannotConnectToHost:
                printHandledError(error)
            default:
                printUnhandledError(error)
            }
        default:
            printHandledError(error)
        }
        
        // We were always going to the same place.
        // I thought the above might be useful in a more robust app
        // which handles different errors more intelligently.0
        isConnected = false
        closeConnection()
        
        // Here we'll try and reconnect with a pseudo-exponential-backoff
        DispatchQueue.main.async {
            self.startAttemptingToReconnect()
        }
        
    }
    
    private func startAttemptingToReconnect() {
        print("attempting to reconnect...")
        isAttemptingReconnect = true
        
        
        // Avoid creating another timer if there's already one running
        if self.reconnectTimer?.isValid ?? false {
            return
        }
        
        self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: untilNextAttempt,
                                              repeats: false) { timer in
            // If connected we can stop attempting to reconnect
            if self.isConnected {
                return
            }
            
            // psuedo-exponential-backoff
            self.untilNextAttempt *= 2
            if self.untilNextAttempt > self.maxTimeToWaitBeforeNextAttempt {
                self.untilNextAttempt = 1
            }
            
            self.connect()
            
            print("waiting \(self.untilNextAttempt)s until next attempt")
            self.startAttemptingToReconnect()
        }
    
    }
}

extension LocationTrackingService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        print("Web socket opened")
        isConnected = true
        isAttemptingReconnect = false
        reconnectTimer?.invalidate()
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        print("Web socket closed")
        isConnected = false
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        handleError(error)
    }
}
