//
//  Notifications.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 12/7/22.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    let center = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        
        center.delegate = self
    }
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Notifications authorization: \(granted)")
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func buildNotification(_ msg: String) {
        let content = UNMutableNotificationContent()
        content.body = NSString.localizedUserNotificationString(forKey: msg, arguments: nil)
         
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "btssAlert",
                                            content: content,
                                            trigger: trigger)
        
        center.add(request) { (error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendActivateNotification() {
        let msg =
        """
        An ACTIVE SHOOTER has been reported at your school. The btSchoolSafety
        system has been activated and your phone’s location is automatically sharing your
        precise location with first responders. Run! Hide! Fight!
        """
        buildNotification(msg)
    }
    
    func sendDeactivateNotification() {
        let msg =
        """
        ALL CLEAR. There is no longer any threat at your school and your app
        is no longer actively monitoring your location.
        """
        buildNotification(msg)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
}
