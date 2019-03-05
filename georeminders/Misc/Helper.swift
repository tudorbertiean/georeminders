//
//  Helper.swift
//  bert8270_final
//
//  Created by Tudor Bertiean on 2018-04-05.
//  Copyright © 2018 wlu. All rights reserved.
//

import Foundation
import os
import UIKit
import CoreLocation
import UserNotifications

class Helper {
    static func showAlert(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
    
    static func saveData() {
        DataStore.sharedInstance.saveDeck()
        UserDefaults.standard.synchronize() // must synchronize
    }
    
    static func checkLocationAccess(viewcontroller: UIViewController) -> Bool {
        var isAble = true
        // Check if location services are enabled
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            Helper.showAlert(controller: viewcontroller, title: "Sorry!", message: "Geofencing is not supported on this device, we apologize for the inconvinience.")
            isAble = false
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            Helper.showAlert(controller: viewcontroller, title: "Warning", message: "You first need to enable location services for GeoReminders for the notifications to work. Go into your phone's Settings app and locate 'GeoReminders' and enable your location for 'Always'.")
            isAble = false
        }
        
        return isAble
    }
    
    // AbleHandler is needed because the 'getNotificationSettings' is calculated in
    // another thread. We need to detect when that thread retrieves the bool
    typealias AbleHandler = (_ able: Bool) -> Void
    
    static func checkNotificationAccess(completionHandler: @escaping AbleHandler){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
    static func convertCoordToAddress(location: CLLocation, locationText: UITextField) {
        let geocoder = CLGeocoder()
        var addressString = ""
        // Look up the location and pass it to the completion handler
        // Geocode Location
        geocoder.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                var placemark:CLPlacemark!
                if let count = placemarks?.count {
                    if error == nil && count > 0 {
                        placemark = placemarks![0] as CLPlacemark
                        if placemark.subThoroughfare != nil {
                            addressString = placemark.subThoroughfare! + " "
                        }
                        if placemark.thoroughfare != nil {
                            addressString = addressString + placemark.thoroughfare! + ", "
                        }
                        if placemark.postalCode != nil {
                            addressString = addressString + placemark.postalCode! + " "
                        }
                        if placemark.locality != nil {
                            addressString = addressString + placemark.locality! + ", "
                        }
                        if placemark.administrativeArea != nil {
                            addressString = addressString + placemark.administrativeArea! + " "
                        }
                        if placemark.country != nil {
                            addressString = addressString + placemark.country!
                        }
                        
                        locationText.text = addressString
                    }
                }
        })
    }
    
    // CompletionHandler is needed because the 'geocodeAddressString' is calculated in
    // another thread. We need to detect when that thread retrieves the coordinate
    typealias CompletionHandler = (_ coordinate: CLLocationCoordinate2D?) -> Void

    static func convertAddressToCoord(address: String, locationText: UITextField, completionHandler: @escaping CompletionHandler) {
        var coordinate: CLLocationCoordinate2D? = nil
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // Process Response
            if error != nil {
            locationText.text = "Unknown location, please try another"
                
            } else {
                var location: CLLocation?
                
                if let placemarks = placemarks, placemarks.count > 0 {
                    location = placemarks.first?.location
                }
                
                if let location = location {
                    coordinate = location.coordinate
                } else {
                    locationText.text = "Unknown location, please try another"
                }
                
                completionHandler(coordinate)
            }
        }
    }
}
