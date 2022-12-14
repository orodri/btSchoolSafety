//
//  Backend.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import Foundation

enum PanicType {
    case activeShooting, fire, other
}

enum StatusType {
    case medAssistance, safe, shooter, none
}

func postPanic(_ panic: PanicType) async {
    let url = serverHttpUrl.appendingPathComponent("/panic")
    
    var jsonObj: [String: Any?] = [
        "anonIdentifier": System.shared.anonIdentifier
    ]
    
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
    let url = serverHttpUrl.appendingPathComponent("/register")
    
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

func postStatus(_ status: StatusType) async {
    
    let url = serverHttpUrl.appendingPathComponent("/api/status")
    
    var jsonObj: [String: Any?] = [
        "anonIdentifier": System.shared.anonIdentifier
    ]
    switch (status) {
    case .medAssistance:
        jsonObj["type"] = "requesting-medical"
    case .safe:
        jsonObj["type"] = "is-safe"
    case .shooter:
        jsonObj["type"] = "sees-shooter"
    case .none:
        jsonObj["type"] = nil
    }
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
        print("postStatus: jsonData serialization error")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        print("postStatus: \(response)")
    } catch {
        print("postStatus: NETWORKING ERROR")
    }
}
