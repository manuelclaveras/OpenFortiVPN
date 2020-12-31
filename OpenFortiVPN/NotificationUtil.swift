//
//  NotificationUtil.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 31/12/2020.
//

import Foundation
import UserNotifications

class NotificationUtil {

    ///This method uses the notification center to schedule a notification.
    ///Default time interval is 10 seconds and notifications are not repeated
    ///
    ///- parameters:
    /// - title: the title of the notification
    /// - subtitle: the subtitle of the notification
    /// - body: the message to be displayed to the user
    static func sendNotification(title: String, subtitle: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "openfortivpn.id.1", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
