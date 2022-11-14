//
//  Backend.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import Foundation

fileprivate let serverUrlKey = "SERVER_URL"

enum PanicType {
    case activeShooting, fire, other
}

func postPanic(_ panic: PanicType) async {
    guard let serverUrl = Bundle.main.object(forInfoDictionaryKey: serverUrlKey) as? String,
          let serverUrl = URL(string: serverUrl.replacingOccurrences(of: "\\", with: "")) else {
        fatalError("\(serverUrlKey) not set")
    }
    
    let url = serverUrl.appendingPathComponent("/panic")
    
    var jsonObj: [String: String] = [:]
    switch (panic) {
    case .activeShooting:
        jsonObj["type"] = "active-shooting"
    case .fire:
        jsonObj["type"] = "fire"
    case .other:
        jsonObj["type"] = "other"
    }
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
        print("postPanic: jsonData serialization error")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        print("postPanic: \(response)")
    } catch {
        print("postPanic: NETWORKING ERROR")
    }
}

func postRegister() async {
    guard let serverUrl = Bundle.main.object(forInfoDictionaryKey: serverUrlKey) as? String,
          let serverUrl = URL(string: serverUrl.replacingOccurrences(of: "\\", with: "")) else {
        fatalError("\(serverUrlKey) not set")
    }
    
    let url = serverUrl.appendingPathComponent("/register")
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
            print("postRegister: failed JSON deserialization")
            return
        }
        guard let assignedIdentifier = jsonObj["anon_identifier"] as? String else {
            print("postRegister: failed to retrieve anon_identifier")
            return
        }
        
        DispatchQueue.main.async {
            System.shared.anonIdentifier = assignedIdentifier
        }
       
        
        print("postRegister: \(response)")
    } catch {
        print("postRegister: NETWORKING ERROR")
    }
}

func postNearest() async {
    print("postNearest:")
    
    let beacons = Beacons.shared.beacons
        .filter { $0.accuracy > 0 }
        .sorted { Double(truncating: $0.minor) < Double(truncating: $1.minor) }
    
    let nearest = beacons.first
    
    guard let serverUrl = Bundle.main.object(forInfoDictionaryKey: serverUrlKey) as? String,
          let serverUrl = URL(string: serverUrl.replacingOccurrences(of: "\\", with: "")) else {
        fatalError("\(serverUrlKey) not set")
    }
    
    let url = serverUrl.appendingPathComponent("/nearest")
    
    var jsonObj: [String:Any] = [:]
    jsonObj["anonIdentifier"] = System.shared.anonIdentifier
    jsonObj["nearest"] = nil
    if let nearest = nearest {
        jsonObj["nearest"] = Int(truncating: nearest.minor)
    }
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
        print("postNearest: jsonData serialization error")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    
    do {
        print("postNearest: with \(jsonData.description)")
        let (_, response) = try await URLSession.shared.data(for: request)
        print("postNearest: \(response)")
    } catch {
        print("postNearest: NETWORKING ERROR")
    }
}
