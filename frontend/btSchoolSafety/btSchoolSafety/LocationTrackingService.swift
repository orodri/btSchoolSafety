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
        let url = serverWsUrl.appendingPathComponent("/ws/nearest/")
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
    
    func sendNearest(_ nearest: Int?) {
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
    
    func connect() {
        LocationTracker.shared.$beacons.sink() { [self] beacons in
            let beacon = beacons
                .filter { $0.accuracy > 0 }
                .sorted { $0.accuracy < $1.accuracy }
                .first
            
            var nearest: Int? = nil
            if let beacon = beacon {
                nearest = Int(truncating: beacon.minor)
            }
            
            if nearest != previousNearestBeaconMinor {
                self.sendNearest(nearest)
            }
            
            previousNearestBeaconMinor = nearest
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
