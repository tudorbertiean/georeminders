//
//  AppDelegate.swift
//  bert8270_final
//
//  Created by Tudor Bertiean on 2018-03-21.
//  Copyright © 2018 wlu. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Requests permission for location tracking
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Requests permission for notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Helper.saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Create the notification
    func createNotification(forRegion region: CLRegion!) {
        if let notification = getNotification(identifier: region.identifier) {
            let content = UNMutableNotificationContent()
            content.body = NSString.localizedUserNotificationString(forKey: (notification.getMessage()), arguments: nil)
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "ca.wlu.bert8270_final"
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest.init(identifier: "alert", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
    }
    
    func getNotification(identifier: String) -> Notification? {
        _ = DataStore() // get the Singleton instance
        DataStore.sharedInstance.loadDeck() // un-archive data
        let notifications = (DataStore.sharedInstance.getDeck().getNotifications())
        let notification = notifications.first(where:{$0.getMessage() == identifier})
        return notification
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    // Detect when user enters one of the geofences
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            createNotification(forRegion: region)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Needed to display notifications when application is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive: UNNotificationResponse,
                                withCompletionHandler: @escaping ()->()) {
        withCompletionHandler()
    }
}

