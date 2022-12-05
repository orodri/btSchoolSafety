//
//  CLBeacon+btss.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 12/4/22.
//

import CoreLocation

extension CLBeacon {
    var label: String {
        get {
            return "\(self.uuid.uuidString):\(self.major):\(self.minor)"
        }
    }
}
