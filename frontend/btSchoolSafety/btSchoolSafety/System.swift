//
//  System.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import Foundation

class System: ObservableObject {
    
    @Published var isWaitingForActivation = false
    @Published var anonIdentifier: String?
    @Published var isActivated = false
    
    static let shared = System()
    
    private init() {}
    
}

class SystemStatusResponse: Codable {
    let systemStatus: SystemStatus
}

class SystemStatus: Codable {
    let isActive: Bool
    let emergencyType: String?
}
