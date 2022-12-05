//
//  Config.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 12/4/22.
//

import Foundation

let proximityUuid = {
    guard let uuid = Bundle.main.object(forInfoDictionaryKey: "PROXIMITY_UUID") as? String,
          let uuid = UUID(uuidString: uuid) else {
        fatalError("PROXIMITY_UUID not set. Is Config.xcconfig correct?")
    }
    
    return uuid
}()

let serverHttpUrl = {
    guard let url = Bundle.main.object(forInfoDictionaryKey: "SERVER_URL") as? String,
          let url = URL(string: url.replacingOccurrences(of: "\\", with: "")) else {
        fatalError("SERVER_URL not set. Is Config.xcconfig correct?")
    }
    
    return url
}()

let serverWsUrl = {
    guard let url = Bundle.main.object(forInfoDictionaryKey: "SERVER_WS_URL") as? String,
          let url = URL(string: url.replacingOccurrences(of: "\\", with: "")) else {
        fatalError("SERVER_WS_URL not set. Is Config.xcconfig correct?")
    }
    
    return url
}()
