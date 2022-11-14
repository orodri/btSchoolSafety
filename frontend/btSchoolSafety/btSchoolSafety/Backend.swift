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
