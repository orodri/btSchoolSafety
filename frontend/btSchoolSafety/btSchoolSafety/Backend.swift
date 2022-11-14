//
//  Backend.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import Foundation

fileprivate let serverUrlKey = "SERVER_URL"

func postPanic() async {
    guard let serverUrl = Bundle.main.object(forInfoDictionaryKey: serverUrlKey) as? String,
          let serverUrl = URL(string: serverUrl.replacingOccurrences(of: "\\", with: "")) else {
        fatalError("\(serverUrlKey) not set")
    }
    
    let url = serverUrl.appendingPathComponent("/panic")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        print("postPanic: \(response)")
    } catch {
        print("postPanic: NETWORKING ERROR")
    }
}
