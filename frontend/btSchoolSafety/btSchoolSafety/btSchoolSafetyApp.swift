//
//  btSchoolSafetyApp.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/12/22.
//

import SwiftUI

@main
struct btSchoolSafetyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        LocationTracker.shared.checkAuthorizationAndTrackIfNeeded()
        
        NotificationManager.shared.requestAuthorization()
        
        LocationTrackingService.shared.attemptToRegisterAndBeginListeningForActivation()
        
        return true
    }
}
